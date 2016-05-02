require 'spec_helper'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr/ptr_record'
end

TEST_INSTANCE_ID = 'e3de5602-98a1-4fcf-8d11-74e0e777ba09'

describe Fog::DNS::Rackspace, :vcr do
  let(:service) do
    Fog::DNS::Rackspace.new({
      :rackspace_api_key  => ENV['RS_API_KEY'],
      :rackspace_username => ENV['RS_USERNAME'],
      :rackspace_region   => ENV['RS_REGION_NAME']
    })
  end

  let(:compute) do
    Fog::Compute.new({
      :provider           => 'Rackspace',
      :rackspace_api_key  => ENV['RS_API_KEY'],
      :rackspace_username => ENV['RS_USERNAME'],
      :rackspace_region   => ENV['RS_REGION_NAME']
    })
  end

  let(:server) do
    compute.servers.find(TEST_INSTANCE_ID).first
  end

  # let(:ptr_records){ service.ptr_records.all }
  # let(:ptr_record){ ptr_records.first }

  it "has links" do
    service.ptr_records
    ptr = Fog::DNS::Rackspace::PtrRecord.new
    # ptr = service.ptr_records.new
    ptr.set_target(server)
    link_data = ptr.to_hash[:link]
    expect(link_data[:rel]).to eq("cloudServersOpenStack")
    expect(link_data[:href]).to eq(server.links[0]['href'])
  end

  it "has records" do
    # expect(ptr_record.records).not_to be_empty
  end

  it "is creatable" do
    # service.ptr_records.new.save({})
  end
end
