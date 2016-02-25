require 'spec_helper'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr/orchestration'
end

describe Fog::Rackspace::Orchestration, :vcr do

  let!(:service) do
    Fog::Rackspace::Orchestration.new({
      :rackspace_api_key  => ENV['RS_API_KEY'],
      :rackspace_username => ENV['RS_USERNAME'],
      :rackspace_region   => ENV['RS_REGION_NAME']
    })
  end

  let!(:stacks){ service.stacks }
  let(:stack){ stacks.first }

  let!(:resources){ stack.resources }
  let(:resource){ resources.first }

  let!(:events){ stack.events }
  let(:event){ events.first }

  let!(:resource_events){ resource.events }
  let(:resource_event){ resource_events.first }

  let(:template){ stack.template }
  let(:redis_template){ File.read("spec/support/redis_template.yml") }

  describe "::Stack" do
    it "has events" do
      expect(events).not_to be_empty
    end

    it "has resources" do
      expect(resources).not_to be_empty
    end

    it "is indexable" do
      expect(stacks).not_to be_empty
    end

    it "is getable" do
      expect(service.stacks.get(stack.stack_name, stack.id).id).to eq(stack.id)
    end

    it "accepts query string arguments" do
      stacks = service.stacks.all(sort_key: "stack_name", sort_dir: "asc")
      expect(stacks.first.stack_name).to eq "abc"
      expect(stacks.last.stack_name).to eq "def"
    end

    it "has a template" do
      expect(stack.template.description).to eq(template.description)
    end

    it "is updatable" do
      stack.save({:template => redis_template})
    end

    it "is creatable" do
      service.stacks.new.save({
        :stack_name => "a_redis_stack",
        :template   => redis_template
      })
    end

    it "is adoptable" do
      service.stacks.adopt({
        :stack_name => "a_redis_stack",
        :template   => redis_template
      })
    end

    it "is abandonable" do
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

    it "is deletable" do
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

    it "is previewable" do
      p = service.stacks.preview({
        :stack_name => "a_redis_template",
        :template   => redis_template
      })

      expect(p.id).to eq("None")
      expect(p.stack_name).to eq("a_redis_template")
    end

    it "provides build info" do
      data = service.stacks.build_info
      expect(data['engine'].nil?).to eq false
      expect(data['fusion-api'].nil?).to eq false
      expect(data['api'].nil?).to eq false
    end
  end

  describe "Event" do
    context "when part of a stack" do
      it "belongs to a stack" do
        expect(event.stack.id).to eq(stack.id)
      end

      it "is indexable" do
        expect(events).not_to be_empty
      end

      it "accepts query string arguments" do
        events = stack.events.all(stack, sort_key: "resource_name", sort_dir: "desc", limit: 3)
        expect(events.count).to eq(3)
        expect(events.first.resource_name).to eq("def")
        expect(events.last.resource_name).to eq("redis_server_config")
      end
    end

    context "when part of a resource" do
      it "belongs to a resource" do
        expect(resource_event.resource.id).to eq(resource.id)
      end

      it "is getable" do
        stack    = service.stacks.get("abc", "6451682a-29cc-4c32-a847-b6feb98c81ff")
        resource = stack.resources.first
        event    = resource.events.first
        expect(service.events.get(stack, resource, event.id).id).to eq(event.id)
      end
    end

    it "accepts query string arguments" do
      e = resource.events.first
      events = resource.events.all(e, sort_key: "resource_name", sort_dir: "desc")
      expect(events.first.event_time >= events.last.event_time).to eq(true)
    end
  end

  describe "Resource" do
    let!(:template) do
      resource.template
    end

    it "belongs to a stack" do
      expect(resource.stack.id).to eq(stack.id)
    end

    it "has metadata" do
      expect(resource.metadata).to eq({})
    end

    it "has a template" do
      expect(template).to be_nil
    end

    it "accepts query string arguments" do
      stacks = stack.resources.all(stack, nested_depth: 0)
      expect(stacks.count).to eq(4)
    end
  end

  describe "Template" do
    it "has these attributes" do
      %w{description heat_template_version parameters resources}.each do |a|
        expect(template.send(a)).not_to be_empty
      end
    end

    it "is validatable" do
      t = service.templates.validate({:template => redis_template})
      expect(t.description).to eq "This is a Heat template to deploy a standalone redis server on\nRackspace Cloud Servers\n"
    end
  end
end
