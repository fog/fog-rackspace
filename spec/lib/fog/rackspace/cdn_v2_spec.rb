require 'spec_helper'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr/cdn_v2'
end

describe Fog::Rackspace::CDNV2, :vcr do

  let(:cdn_service) do
    Fog::Rackspace::CDNV2.new({
      :rackspace_api_key  => ENV['RS_API_KEY'],
      :rackspace_username => ENV['RS_USERNAME'],
      :rackspace_region   => ENV['RS_REGION_NAME']
    })
  end

  let(:domain){ "some-domain-name.com" }
  let(:services){ cdn_service.services }
  let(:flavors){ cdn_service.flavors }
  let(:flavor){ flavors.first }

  describe "Ping" do
    it "is pingable" do
      expect(cdn_service.ping).to eq(true)
    end
  end

  describe "Home Document" do
    it "is getable" do
      expect(cdn_service.home_document["resources"].size).to eq(4)
    end
  end

  describe "Service" do
    before do
      @service ||= begin
        s = cdn_service.services.new
        s.name = domain
        s.flavor_id = "cdn"
        s.add_domain "www.#{Time.now.usec}.com"
        s.add_origin "www.#{Time.now.usec}.com", rules: [
          {name: "SomethingElse", request_url: "hotmail.com"}
        ]
        s.save

        while s.status == "create_in_progress"
          sleep 10
          s.reload
        end

        s
      end
    end

    it "is creatable" do
      expect(@service).to be_truthy
    end

    it "is indexable" do
      expect(services).to_not be_empty
    end

    it "is getable" do
      expect(cdn_service.services.get(@service.id).id).to eq(@service.id)
    end
  end

  describe "flavor" do
    it "is indexable" do
      expect(flavors).not_to be_empty
    end

    it "is getable" do
      expect(cdn_service.flavors.get("cdn").id).to eq("cdn")
    end
  end
end
