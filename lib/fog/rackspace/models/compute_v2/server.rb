require 'fog/compute/models/server'
require 'fog/rackspace/models/compute_v2/metadata'

module Fog
  module Compute
    class RackspaceV2
      class Server &lt; Fog::Compute::Server

        identity :id
#        attribute :instance_name, :aliases =&gt; 'OS-EXT-SRV-ATTR:instance_name'

        attribute :addresses
        attribute :flavor
        attribute :host_id, :aliases =&gt; 'hostId'
        attribute :image
        attribute :metadata
        attribute :links
        attribute :name

        # @!attribute [rw] personality
        # @note This attribute is only used for server creation. This field will be nil on subsequent retrievals.
        # @return [Hash] Hash containing data to inject into the file system of the cloud server instance during
        #                server creation.
        # @example To inject fog.txt into file system
        #   :personality =&gt; [{ :path =&gt; '/root/fog.txt',
        #                      :contents =&gt; Base64.encode64('Fog was here!')
        #                   }]
        # @see #create
        # @see http://docs.openstack.org/api/openstack-compute/2/content/Server_Personality-d1e2543.html
        attribute :personality
        attribute :progress
        attribute :accessIPv4
        attribute :accessIPv6
#        attribute :availability_zone, :aliases =&gt; 'OS-EXT-AZ:availability_zone'
        attribute :user_data_encoded
        attribute :state,       :aliases =&gt; 'status'
        attribute :created,     :type =&gt; :time
        attribute :updated,     :type =&gt; :time

        attribute :tenant_id
        attribute :user_id
        attribute :key_name
        attribute :fault
        attribute :config_drive
        attribute :os_dcf_disk_config, :aliases =&gt; 'OS-DCF:diskConfig'
#        attribute :os_ext_srv_attr_host, :aliases =&gt; 'OS-EXT-SRV-ATTR:host'
#        attribute :os_ext_srv_attr_hypervisor_hostname, :aliases =&gt; 'OS-EXT-SRV-ATTR:hypervisor_hostname'
#        attribute :os_ext_srv_attr_instance_name, :aliases =&gt; 'OS-EXT-SRV-ATTR:instance_name'
#        attribute :os_ext_sts_power_state, :aliases =&gt; 'OS-EXT-STS:power_state'
        attribute :os_ext_sts_task_state, :aliases =&gt; 'OS-EXT-STS:task_state'
#        attribute :os_ext_sts_vm_state, :aliases =&gt; 'OS-EXT-STS:vm_state'

        attr_reader :password
        attr_writer :image_id, :flavor_id, :nics    # , :os_scheduler_hints
        attr_accessor :block_device_mapping, :block_device_mapping_v2  # boot_volume_id attribute in rackspace

        # In some cases it's handy to be able to store the project for the record, e.g. swift doesn't contain project
        # info in the result, so we can track it in this attribute based on what project was used in the request
        attr_accessor :project

        def initialize(attributes = {})
          # Old 'connection' is renamed as service and should be used instead
          prepare_service_value(attributes)

#          self.security_groups = attributes.delete(:security_groups)
          self.min_count = attributes.delete(:min_count)
          self.max_count = attributes.delete(:max_count)
          self.nics = attributes.delete(:nics)
#          self.os_scheduler_hints = attributes.delete(:os_scheduler_hints)
          self.block_device_mapping = attributes.delete(:block_device_mapping)
          self.block_device_mapping_v2 = attributes.delete(:block_device_mapping_v2)

          super
        end
=begin
        def metadata
          @metadata ||= begin
            Fog::Compute::OpenStack::Metadata.new(:service =&gt; service,
                                                  :parent  =&gt; self)
          end
        end

        def metadata=(new_metadata = {})
          return unless new_metadata
          metas = []
          new_metadata.each_pair { |k, v| metas &lt;&lt; {"key" =&gt; k, "value" =&gt; v} }
          @metadata = metadata.load(metas)
        end
=end
        def user_data=(ascii_userdata)
          self.user_data_encoded = [ascii_userdata].pack('m') if ascii_userdata
        end

        def destroy
          requires :id
          service.delete_server(id)
          true
        end

        def images
          requires :id
          service.images(:server =&gt; self)
        end

=begin
        def all_addresses
          # currently openstack API does not tell us what is a floating ip vs a fixed ip for the vm listing,
          # we fall back to get all addresses and filter sadly.
          # Only includes manually-assigned addresses, not auto-assigned
          @all_addresses ||= service.list_all_addresses.body["floating_ips"].select { |data| data['instance_id'] == id }
        end

        def reload
          @all_addresses = nil
          super
        end
=end
        # returns all ip_addresses for a given instance
        # this includes both the fixed ip(s) and the floating ip(s)
        def ip_addresses
          addresses ? addresses.values.flatten.collect { |x| x['addr'] } : []
        end
=begin
        def floating_ip_addresses
          all_floating = if addresses
                           flattened_values = addresses.values.flatten
                           flattened_values.select { |d| d["OS-EXT-IPS:type"] == "floating" }.collect { |a| a["addr"] }
                         else
                           []
                         end

          # Return them all, leading with manually assigned addresses
#          manual = all_addresses.collect { |addr| addr["ip"] }

          all_floating.sort do |a, b|
            a_manual = manual.include? a
            b_manual = manual.include? b

            if a_manual &amp;&amp; !b_manual
              -1
            elsif !a_manual &amp;&amp; b_manual
              1
            else
              0
            end
          end
          all_floating.empty? ? manual : all_floating
        end
=end
=begin
        def public_ip_addresses
          if floating_ip_addresses.empty?
            if addresses
              addresses.select { |s| s[0] =~ /public/i }.collect { |a| a[1][0]['addr'] }
            else
              []
            end
          else
            floating_ip_addresses
          end
        end

        def floating_ip_address
          floating_ip_addresses.first
        end

        def public_ip_address
          public_ip_addresses.first
        end

        def private_ip_addresses
          rfc1918_regexp = /(^10\.|^172\.1[6-9]\.|^172\.2[0-9]\.|^172.3[0-1]\.|^192\.168\.)/
          almost_private = ip_addresses - public_ip_addresses - floating_ip_addresses
          almost_private.select { |ip| rfc1918_regexp.match ip }
        end

        def private_ip_address
          private_ip_addresses.first
        end
=end

        # Server's public IPv4 address
        # @return [String] public IPv4 address
        def public_ip_address
          accessIPv4
        end

        # Server's private IPv4 address
        # @return [String] private IPv4 address
        def private_ip_address
          addresses['private'].select{|a| a["version"] == 4}[0]["addr"] rescue ''
        end

        attr_reader :image_id

        attr_writer :image_id

        attr_reader :flavor_id

        attr_writer :flavor_id

        def ready?
          state == 'ACTIVE'
        end

        def failed?
          state == 'ERROR'
        end

        def change_password(admin_password)
          requires :id
          service.change_server_password(id, admin_password)
          true
        end


        def rebuild(image_id, name, admin_pass = nil, metadata = nil, personality = nil)
          requires :id
          service.rebuild_server(id, image_id, name, admin_pass, metadata, personality)
          true
        end

        def resize(flavor_id)
          requires :id
          service.resize_server(id, flavor_id)
          true
        end

        def revert_resize
          requires :id
          service.revert_resize_server(id)
          true
        end

        def confirm_resize
          requires :id
          service.confirm_resize_server(id)
          true
        end
=begin
        def security_groups
          requires :id

          groups = service.list_security_groups(:server_id =&gt; id).body['security_groups']

          groups.map do |group|
            Fog::Compute::RackspaceV2::SecurityGroup.new group.merge(:service =&gt; service)
          end
        end

        attr_writer :security_groups
=end
        def reboot(type = 'SOFT')
          requires :id
          service.reboot_server(id, type)
          true
        end

        def stop
          requires :id
          service.stop_server(id)
        end

        def pause
          requires :id
          service.pause_server(id)
        end

        def suspend
          requires :id
          service.suspend_server(id)
        end

        def start
          requires :id

          case state.downcase
          when 'paused'
            service.unpause_server(id)
          when 'suspended'
            service.resume_server(id)
          else
            service.start_server(id)
          end
        end

        def shelve
          requires :id
          service.shelve_server(id)
        end

        def unshelve
          requires :id
          service.unshelve_server(id)
        end

        def shelve_offload
          requires :id
          service.shelve_offload_server(id)
        end

        def create_image(name, metadata = {})
          requires :id
          service.create_image(id, name, metadata)
        end

        def console(log_length = nil)
          requires :id
          service.get_console_output(id, log_length)
        end

        def migrate
          requires :id
          service.migrate_server(id)
        end

        def live_migrate(host, block_migration, disk_over_commit)
          requires :id
          service.live_migrate_server(id, host, block_migration, disk_over_commit)
        end

        def evacuate(host = nil, on_shared_storage = nil, admin_password = nil)
          requires :id
          service.evacuate_server(id, host, on_shared_storage, admin_password)
        end

        def associate_address(floating_ip)
          requires :id
          service.associate_address id, floating_ip
        end

        def disassociate_address(floating_ip)
          requires :id
          service.disassociate_address id, floating_ip
        end

        def reset_vm_state(vm_state)
          requires :id
          service.reset_server_state id, vm_state
        end

        attr_writer :min_count

        attr_writer :max_count

        def networks
          service.networks(:server =&gt; self)
        end

        def volumes
          requires :id
          service.volumes.select do |vol|
            vol.attachments.find { |attachment| attachment["serverId"] == id }
          end
        end

        def volume_attachments
          requires :id
          service.get_server_volumes(id).body['volumeAttachments']
        end

        def attach_volume(volume_id, device_name)
          requires :id
          service.attach_volume(volume_id, id, device_name)
          true
        end

        def detach_volume(volume_id)
          requires :id
          service.detach_volume(id, volume_id)
          true
        end

        def save
          raise Fog::Errors::Error, 'Resaving an existing object may create a duplicate' if persisted?
          requires :flavor_id, :name
          requires_one :image_id, :block_device_mapping, :block_device_mapping_v2
          options = {
            'personality'             =&gt; personality,
            'accessIPv4'              =&gt; accessIPv4,
            'accessIPv6'              =&gt; accessIPv6,
#            'availability_zone'       =&gt; availability_zone,
            'user_data'               =&gt; user_data_encoded,
            'key_name'                =&gt; key_name,
            'config_drive'            =&gt; config_drive,
#            'security_groups'         =&gt; @security_groups,
            'min_count'               =&gt; @min_count,
            'max_count'               =&gt; @max_count,
            'nics'                    =&gt; @nics,
#            'os:scheduler_hints'      =&gt; @os_scheduler_hints,
            'block_device_mapping'    =&gt; @block_device_mapping,
            'block_device_mapping_v2' =&gt; @block_device_mapping_v2,
          }
          options['metadata'] = metadata.to_hash unless @metadata.nil?
          options = options.reject { |_key, value| value.nil? }
          data = service.create_server(name, image_id, flavor_id, options)
          merge_attributes(data.body['server'])
          true
        end

        def setup(credentials = {})
          requires :ssh_ip_address, :identity, :public_key, :username
          ssh = Fog::SSH.new(ssh_ip_address, username, credentials)
          ssh.run([
                    %(mkdir .ssh),
                    %(echo "#{public_key}" &gt;&gt; ~/.ssh/authorized_keys),
                    %(passwd -l #{username}),
                    %(echo "#{Fog::JSON.encode(attributes)}" &gt;&gt; ~/attributes.json),
                    %(echo "#{Fog::JSON.encode(metadata)}" &gt;&gt; ~/metadata.json)
                  ])
        rescue Errno::ECONNREFUSED
          sleep(1)
          retry
        end

      end
    end
  end
end
