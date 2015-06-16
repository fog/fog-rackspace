require 'spec_helper'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr/orchestration'
end

describe Fog::Rackspace::Orchestration do

  let!(:service) do
    VCR.use_cassette('service') do
      Fog::Rackspace::Orchestration.new({
        :rackspace_api_key  => "api_key",
        :rackspace_username => "test_account"
      })
    end
  end

  let!(:stacks){ VCR.use_cassette('stacks'){ service.stacks }  }
  let(:stack){ stacks.first }

  let!(:resources){ VCR.use_cassette('stack_resources'){ stack.resources }  }
  let(:resource){ resources.first }

  let!(:events){ VCR.use_cassette('stack_events'){ stack.events } }
  let(:event){ events.first }

  let!(:resource_events){ VCR.use_cassette('resource_events'){ resource.events } }
  let(:resource_event){ resource_events.first }

  let(:template){ VCR.use_cassette('stack_template'){ stack.template }  }
  let(:redis_template){ File.read("spec/support/redis_template.yml") }

  describe "::Stack" do
    it "has events" do
      VCR.use_cassette('index_stack_event') do
        expect(events).not_to be_empty
      end
    end

    it "has resources" do
      VCR.use_cassette('index_stack_resources') do
        expect(resources).not_to be_empty
      end
    end

    it "is indexable" do
      VCR.use_cassette('index_stacks') do
        expect(stacks).not_to be_empty
      end
    end

    it "is getable" do
      VCR.use_cassette('stack_getable') do
        expect(service.stacks.get(stack.stack_name, stack.id).id).to eq(stack.id)
      end
    end

    it "accepts query string arguments" do
      VCR.use_cassette('stacks_via_query_string') do
        stacks = service.stacks.all(sort_key: "stack_name", sort_dir: "asc")
        expect(stacks.first.stack_name).to eq "abc"
        expect(stacks.last.stack_name).to eq "def"
      end
    end

    it "has a template" do
      VCR.use_cassette('get_template') do
        expect(stack.template.description).to eq(template.description)
      end
    end

    it "is updatable" do
      VCR.use_cassette('update_stack') do
        stack.save({:template => redis_template})
      end
    end

    it "is creatable" do
      VCR.use_cassette('create_stack') do
        service.stacks.new.save({
          :stack_name => "a_redis_stack",
          :template   => redis_template
        })
      end
    end

    it "is adoptable" do
      VCR.use_cassette('adopt_stack') do
        service.stacks.adopt({
          :stack_name => "a_redis_stack",
          :template   => redis_template
        })
      end
    end

    it "is abandonable" do
      VCR.use_cassette('abandon_stack') do
        count = service.stacks.size

        stack_data = service.stacks.create({
          :stack_name => "a_redis_stack",
          :template   => redis_template
        })

        new_stack = service.stacks.get("a_redis_stack", stack_data['id'])

        expect(service.stacks.size).to eq(count + 1)

        # sleep 260 # When doing it live...

        new_stack.abandon

        # sleep 120

        expect(service.stacks.size).to eq(count)
      end
    end

    it "is deletable" do
      VCR.use_cassette('delete_stack') do
        count = service.stacks.size

        stack_data = service.stacks.create({
          :stack_name => "a_redis_stack",
          :template   => redis_template
        })

        new_stack = service.stacks.get("a_redis_stack", stack_data['id'])

        expect(service.stacks.size).to eq(count + 1)

        # sleep 260 # When doing it live...

        new_stack.delete

        # sleep 120

        expect(service.stacks.size).to eq(count)
      end
    end

    it "is previewable" do
      VCR.use_cassette('preview_stack') do
        p = service.stacks.preview({
          :stack_name => "a_redis_template",
          :template   => redis_template
        })

        expect(p.id).to eq("None")
        expect(p.stack_name).to eq("a_redis_template")
      end
    end

    it "provides build info" do
      VCR.use_cassette('build_info') do
        data = service.stacks.build_info
        expect(data['engine'].nil?).to eq false
        expect(data['fusion-api'].nil?).to eq false
        expect(data['api'].nil?).to eq false
      end
    end
  end

  describe "Event" do
    context "when part of a stack" do
      it "belongs to a stack" do
        VCR.use_cassette('event_belongs_to_a_stack') do
          expect(event.stack.id).to eq(stack.id)
        end
      end

      it "is indexable" do
        VCR.use_cassette('index_events') do
          expect(events).not_to be_empty
        end
      end

      it "accepts query string arguments" do
        VCR.use_cassette('stack_events_via_query') do
          events = stack.events.all(stack, sort_key: "resource_name", sort_dir: "desc", limit: 3)
          expect(events.count).to eq(3)
          expect(events.first.resource_name).to eq("redis_server_config")
          expect(events.last.resource_name).to eq("redis_server")
        end
      end
    end

    context "when part of a resource" do
      it "belongs to a resource" do
        VCR.use_cassette('event_belongs_to_resource') do
          expect(resource_event.resource.id).to eq(resource.id)
        end
      end

      it "is getable" do
        VCR.use_cassette('event_resource_getable') do
          stack    = service.stacks.get("a_redis_stack", "ee648a3b-14a3-4df8-aa58-620a9d67e3e5")
          resource = stack.resources.first
          event    = resource.events.first
          expect(service.events.get(stack, resource, event.id).id).to eq(event.id)
        end
      end
    end

    it "accepts query string arguments" do
      VCR.use_cassette('resource_events_via_query') do
        e = resource.events.first
        events = resource.events.all(e, sort_key: "resource_name", sort_dir: "desc")
        expect(events.first.event_time > events.last.event_time).to eq(true)
      end
    end
  end

  describe "Resource" do
    let!(:template) do
      VCR.use_cassette('resource_template') do
        resource.template
      end
    end

    it "belongs to a stack" do
      expect(resource.stack.id).to eq(stack.id)
    end

    it "has metadata" do
      VCR.use_cassette('resource_metadata') do
        expect(resource.metadata).to eq({})
      end
    end

    it "has a template" do
      expect(template).to be_nil
    end

    it "accepts query string arguments" do
      VCR.use_cassette('resources_via_query_string') do
        stacks = stack.resources.all(stack, nested_depth: 0)
        expect(stacks.count).to eq(4)
      end
    end
  end

  describe "Template" do
    it "has these attributes" do
      %w{description heat_template_version parameters resources}.each do |a|
        expect(template.send(a)).not_to be_empty
      end
    end

    it "is validatable" do
      VCR.use_cassette('validate_template') do
        t = service.templates.validate({:template => redis_template})
        expect(t.description).to eq "This is a Heat template to deploy a standalone redis server on\nRackspace Cloud Servers\n"
      end
    end
  end
end
