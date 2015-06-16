require 'spec_helper'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr/networking_v2'
end

describe Fog::Rackspace::NetworkingV2 do

  let(:net_service) do
    VCR.use_cassette('net_service') do
      data = {
        :rackspace_api_key  => "c8b184b2c1e34662abfdb5d40a035aa0",
        :rackspace_username => "mattdarbytest"
      }

      Fog::Rackspace::NetworkingV2.new(data )
    end
  end

  let(:networks) do
    VCR.use_cassette('networks') do
      net_service.networks
    end
  end

  let(:subnets) do
    VCR.use_cassette('subnets') do
      net_service.subnets
    end
  end

  let(:ports) do
    VCR.use_cassette('ports') do
      net_service.ports
    end
  end

  let(:security_groups) do
    VCR.use_cassette('security_groups') do
      net_service.security_groups
    end
  end

  let(:security_group_rules) do
    VCR.use_cassette('security_group_rules') do
      net_service.security_group_rules
    end
  end

  let(:ip_addresses) do
    VCR.use_cassette('ip_addresses') do
      net_service.ip_addresses
    end
  end

  let(:network){ networks.first }
  let(:subnet){ subnets.first }
  let(:port){ ports.first }
  let(:security_group){ security_groups.first }
  let(:security_group_rule){ security_group_rules.first }
  let(:ip_addresse){ ip_addresses.first }

  describe "Network" do
    it "is creatable" do
      VCR.use_cassette('create_network') do
        created = net_service.networks.new(:name => "ANewNetwork").save
        expect(created).to eq(true)
      end
    end

    it "is indexable" do
      VCR.use_cassette('index_network') do
        expect(networks).not_to be_empty
      end
    end

    it "is getable" do
      VCR.use_cassette('network_getable') do
        expect(net_service.networks.get(network.id).id).to eq(network.id)
      end
    end

    it "is updatable" do
      VCR.use_cassette('update_network') do
        network.name = "SomethingDifferent"
        network.save
        expect(network.name).to eq("SomethingDifferent")
      end
    end

    it "is deletable" do
      VCR.use_cassette('delete_network') do
        count   = net_service.networks.size
        network = net_service.networks.create(:name => "soon_to_be_deleted")
        expect(net_service.networks.size).to eq(count + 1)
        network.destroy
        expect(net_service.networks.size).to eq(count)
      end
    end
  end

  describe "Subnet" do
    it "is creatable" do
      VCR.use_cassette('create_subnet') do
        net_service.networks.new(:name => "ANewNetwork").save

        created = net_service.subnets.new({
                                            :name       => "ANewsubnet",
                                            :cidr       => "192.168.101.1/24",
                                            :network_id => networks.last.id,
                                            :ip_version => "4"
        }).save

        expect(created).to eq(true)
      end
    end

    it "is indexable" do
      VCR.use_cassette('index_subnet') do
        expect(subnets).not_to be_empty
      end
    end

    it "is getable" do
      VCR.use_cassette('subnet_getable') do
        expect(net_service.subnets.get(subnet.id).id).to eq(subnet.id)
      end
    end

    it "is updatable" do
      VCR.use_cassette('update_subnet') do
        subnet.name = "SomethingDifferent"
        subnet.save
        expect(subnet.name).to eq("SomethingDifferent")
      end
    end

    it "is deletable" do
      VCR.use_cassette('delete_subnet') do
        count = net_service.subnets.size
        subnet.destroy
        expect(net_service.subnets.size).to eq(count-1)
      end
    end
  end

  describe "Port" do
    it "is creatable" do
      VCR.use_cassette('create_port') do
        created = net_service.ports.new({
                                          :name => "ANewPort",
                                          :network_id => network.id
        }).save
        expect(created).to eq(true)
      end
    end

    it "is indexable" do
      VCR.use_cassette('index_ports') do
        expect(ports).to be_empty
      end
    end

    it "is getable" do
      VCR.use_cassette('port_getable') do
        expect(net_service.ports.get(port.id).id).to eq(port.id)
      end
    end

    it "is updatable" do
      VCR.use_cassette('update_port') do
        port.name = "SomethingDifferent"
        port.save
        expect(port.name).to eq("SomethingDifferent")
      end
    end

    it "is deletable" do
      VCR.use_cassette('delete_port') do
        count = net_service.ports.size
        port.destroy
        expect(net_service.ports.size).to eq(count - 1)
      end
    end
  end

  describe "SecurityGroup" do
    it "is creatable" do
      VCR.use_cassette('create_security_group') do
        created = net_service.security_groups.new({
                                                    :name => "ASecurityGroup",
                                                    :description => "Something",
                                                    :tenant_id => "930035"
        }).save
        expect(created).to eq(true)
      end
    end

    it "is indexable" do
      VCR.use_cassette('index_security_groups') do
        expect(security_groups).not_to be_empty
      end
    end

    it "is getable" do
      VCR.use_cassette('security_group_getable') do
        expect(net_service.security_groups.get(security_group.id).id).to eq(security_group.id)
      end
    end

    it "is updatable" do
      VCR.use_cassette('update_security_group') do
        security_group.name = "SomethingDifferent"
        security_group.save
        expect(security_group.name).to eq("SomethingDifferent")
      end
    end

    it "is deletable" do
      VCR.use_cassette('delete_security_group') do
        count = net_service.security_groups.size
        security_group.destroy
        expect(net_service.security_groups.size).to eq(count - 1)
      end
    end
  end

  describe "SecurityGroupRule" do
    it "is creatable" do
      VCR.use_cassette('create_security_group_rule') do
        data = {
          :direction         => "ingress",
          :ethertype         => "IPv4",
          :security_group_id => security_group.id
        }

        created = net_service.security_group_rules.new(data).save
        expect(created).to eq(true)
      end
    end

    it "is indexable" do
      VCR.use_cassette('index_security_group_rules') do
        expect(security_group_rules).not_to be_empty
      end
    end

    it "is getable" do
      VCR.use_cassette('security_group_rule_getable') do
        expect(net_service.security_group_rules.get(security_group_rule.id).id).to eq(security_group_rule.id)
      end
    end

    it "is deletable" do
      VCR.use_cassette('delete_security_group_rule') do
        count = net_service.security_group_rules.size
        security_group_rule.destroy
        expect(net_service.security_group_rules.size).to eq(count - 1)
      end
    end
  end

  describe "IP Address" do
    it "is creatable" do
      VCR.use_cassette('create_ip_address') do
        created = net_service.ip_addresses.new(:name => "ANewIpaddress").save
        expect(created).to eq(true)
      end
    end

    it "is indexable" do
      VCR.use_cassette('index_ip_address') do
        expect(ip_addresses).not_to be_empty
      end
    end

    it "is getable" do
      VCR.use_cassette('ip_address_getable') do
        expect(net_service.ip_addresses.get(ip_address.id).id).to eq(ip_address.id)
      end
    end

    it "is updatable" do
      VCR.use_cassette('update_ip_address') do
        ip_address.name = "SomethingDifferent"
        ip_address.save
        expect(ip_address.name).to eq("SomethingDifferent")
      end
    end

    it "is deletable" do
      VCR.use_cassette('delete_ip_address') do
        count   = net_service.ip_addresses.size
        ip_address = net_service.ip_addresses.create(:name => "soon_to_be_deleted")
        expect(net_service.ip_addresses.size).to eq(count + 1)
        ip_address.destroy
        expect(net_service.ip_addresses.size).to eq(count)
      end
    end
  end
end
