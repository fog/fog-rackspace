require 'spec_helper'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr/networking_v2'
end

describe Fog::Rackspace::NetworkingV2, :vcr do

  let(:net_service) do
    data = {
      :rackspace_api_key  => ENV['RS_API_KEY'],
      :rackspace_username => ENV['RS_USERNAME'],
      :rackspace_region   => ENV['RS_REGION_NAME']
    }

    Fog::Rackspace::NetworkingV2.new(data)
  end

  let(:networks){ net_service.networks }
  let(:subnets){ net_service.subnets }
  let(:ports){ net_service.ports }
  let(:security_groups){ net_service.security_groups }
  let(:security_group_rules){ net_service.security_group_rules }
  let(:ip_addresses){ net_service.ip_addresses }
  let!(:network){ networks.first }
  let(:subnet){ subnets.first }
  let(:port){ ports.first }
  let(:security_group){ security_groups.first }
  let(:security_group_rule){ security_group_rules.first }
  let(:ip_addresse){ ip_addresses.first }

  describe "Network" do
    it "is creatable" do
      created = net_service.networks.new(:name => "ANewNetwork").save
      expect(created).to eq(true)
    end

    it "is indexable" do
      expect(networks).not_to be_empty
    end

    it "is getable" do
      expect(net_service.networks.get(network.id).id).to eq(network.id)
    end

    it "is updatable" do
      network.name = "SomethingDifferent"
      network.save
      expect(network.name).to eq("SomethingDifferent")
    end

    it "is deletable" do
      count   = net_service.networks.size
      network = net_service.networks.create(:name => "soon_to_be_deleted")
      expect(net_service.networks.size).to eq(count + 1)
      network.destroy
      expect(net_service.networks.size).to eq(count)
    end
  end

  describe "Subnet" do
    it "is creatable" do
      net_service.networks.new(:name => "ANewNetwork").save

      created = net_service.subnets.new({
        :name       => "ANewsubnet",
        :cidr       => "192.168.101.1/24",
        :network_id => networks.last.id,
        :ip_version => "4"
      }).save

      expect(created).to eq(true)
    end

    it "is indexable" do
      expect(subnets).not_to be_empty
    end

    it "is getable" do
      expect(net_service.subnets.get(subnet.id).id).to eq(subnet.id)
    end

    it "is updatable" do
      subnet.name = "SomethingDifferent"
      subnet.save
      expect(subnet.name).to eq("SomethingDifferent")
    end

    it "is deletable" do
      count = net_service.subnets.size
      subnet.destroy
      expect(net_service.subnets.size).to eq(count-1)
    end
  end

  describe "Port" do
    it "is creatable" do
      net = net_service.networks.new(:name => "ANewNetwork")
      net.save

      created = net_service.subnets.new({
        :name       => "ANewsubnet",
        :cidr       => "192.168.101.1/24",
        :network_id => net.id,
        :ip_version => "4"
      }).save

      created = net_service.ports.new({
        :name => "ANewPort",
        :network_id => net.id
      }).save

      expect(created).to eq(true)
    end

    it "is indexable" do
      expect(net_service.ports).not_to be_empty
    end

    it "is getable" do
      expect(net_service.ports.get(port.id).id).to eq(port.id)
    end

    it "is updatable" do
      port.name = "SomethingDifferent"
      port.save
      expect(port.name).to eq("SomethingDifferent")
    end

    it "is deletable" do
      count = net_service.ports.size
      net_service.ports.last.destroy
      expect(net_service.ports.size).to eq(count - 1)
    end
  end

  describe "SecurityGroup" do
    it "is creatable" do
      created = net_service.security_groups.new({
        :name => "ASecurityGroup",
        :description => "Something",
        :tenant_id => ENV['RS_TENANT_ID'],
      }).save
      expect(created).to eq(true)
    end

    it "is indexable" do
      expect(security_groups).not_to be_empty
    end

    it "is getable" do
      expect(net_service.security_groups.get(security_group.id).id).to eq(security_group.id)
    end

    it "is updatable" do
      security_group.name = "SomethingDifferent"
      security_group.save
      expect(security_group.name).to eq("SomethingDifferent")
    end

    it "is deletable" do
      count = net_service.security_groups.size
      security_group.destroy
      expect(net_service.security_groups.size).to eq(count - 1)
    end
  end

  describe "SecurityGroupRule" do
    it "is creatable" do
      data = {
        :direction         => "ingress",
        :ethertype         => "IPv4",
        :security_group_id => security_group.id
      }

      created = net_service.security_group_rules.new(data).save
      expect(created).to eq(true)
    end

    it "is indexable" do
      expect(security_group_rules).not_to be_empty
    end

    it "is getable" do
      expect(net_service.security_group_rules.get(security_group_rule.id).id).to eq(security_group_rule.id)
    end

    it "is deletable" do
      count = net_service.security_group_rules.size
      security_group_rule.destroy
      expect(net_service.security_group_rules.size).to eq(count - 1)
    end
  end
end
