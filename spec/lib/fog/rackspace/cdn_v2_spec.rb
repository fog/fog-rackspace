require 'spec_helper'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr/cdn_v2'
end

describe Fog::Rackspace::CDNV2 do

  let(:cdn_service) do
    VCR.use_cassette('cdn_service') do
      Fog::Rackspace::CDNV2.new({
                                  :rackspace_api_key  => "c8b184b2c1e34662abfdb5d40a035aa0",
                                  :rackspace_username => "mattdarbytest"
      })
    end
  end

  let(:services) do
    VCR.use_cassette('services') do
      cdn_service.services
    end
  end

  let(:flavors) do
    VCR.use_cassette('flavors') do
      cdn_service.flavors
    end
  end

  let(:service){ services.last }
  let(:flavor){ flavors.first }

  let(:domain){ "some-domain-name.com" }

  describe "Ping" do
    it "is pingable" do
      VCR.use_cassette('ping') do
        expect(cdn_service.ping).to eq(true)
      end
    end
  end

  describe "Home Document" do
    it "is getable" do
      VCR.use_cassette('get_home_document') do
        expect(cdn_service.home_document["resources"].size).to eq(4)
      end
    end
  end

  describe "Service" do
    it "is creatable" do
      VCR.use_cassette('create_service') do
        s = cdn_service.services.new
        s.name = domain
        s.flavor_id = "cdn"
        s.add_domain "#{Time.now.usec}.com"
        s.add_origin "#{Time.now.usec}.com"
        s.save
      end
    end

    it "is indexable" do
      VCR.use_cassette('index_service') do
        expect(services).to_not be_empty
      end
    end

    it "is getable" do
      VCR.use_cassette('service_getable') do
        id = cdn_service.services.first.id
        expect(cdn_service.services.get(id).id).to eq(id)
      end
    end

    it "is updatable" do
      VCR.use_cassette('update_service') do
        s = cdn_service.services.new
        s.name = domain
        s.flavor_id = "cdn"
        s.add_domain "#{Time.now.usec}.com"
        s.add_origin "#{Time.now.usec}.com", rules: [{name: "SomethingElse", request_url: "hotmail.com"}]
        s.save

        op = {op: "replace", path: "/name", value: "skrelnick.com"}

        # sleep 10
        s.reload
        s.add_operation(op)
        s.save
        # sleep 10
        s.reload
        expect(s.name).to eq("skrelnick.com")
      end
    end

    it "is deletable" do
      VCR.use_cassette('delete_service') do
        cdn_service.services.reload
        id = cdn_service.services.first.id
        count = cdn_service.services.size
        service = cdn_service.services.get(id)
        service.destroy
        # sleep 30
        cdn_service.services.reload
        expect(cdn_service.services.size).to eq(count-1)
      end
    end

    it "assets are deletable" do
      VCR.use_cassette('delete_service_assets') do
        s = cdn_service.services.new
        s.name = domain
        s.flavor_id = "cdn"
        s.add_domain "#{Time.now.usec}.com"
        s.add_origin "#{Time.now.usec}.com", rules: [{name: "SomethingElse", request_url: "hotmail.com"}]
        s.save

        s.destroy_assets(url: "/")
      end
    end
  end

  describe "flavor" do
    it "is indexable" do
      VCR.use_cassette('index_flavor') do
        expect(flavors).not_to be_empty
      end
    end

    it "is getable" do
      VCR.use_cassette('flavor_getable') do
        expect(cdn_service.flavors.get("cdn").id).to eq("cdn")
      end
    end
  end
end
