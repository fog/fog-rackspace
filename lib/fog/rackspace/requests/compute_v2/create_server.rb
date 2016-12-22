  module Compute
    class RackspaceV2
      class Real

        def create_server(name, image_id, flavor_id, options = {})
          data = {
            'server' =&gt; {
              'flavorRef' =&gt; flavor_id,
              'name'      =&gt; name
            }
          }
          data['server']['imageRef'] = image_id if image_id

          vanilla_options = ['accessIPv4', 'accessIPv6',
                             'availability_zone', 'user_data', 'key_name',
                             'adminPass', 'config_drive', 'min_count', 'max_count',
                             'return_reservation_id']
          vanilla_options.select { |o| options[o] }.each do |key|
            data['server'][key] = options[key]
          end

=begin
          if options['security_groups']
            # security names requires a hash with a name prefix
            data['server']['security_groups'] =
              Array(options['security_groups']).map do |sg|
                name = if sg.kind_of?(Fog::Compute::RackspaceV2::SecurityGroup)
                         sg.name
                       else
                         sg
                       end
                {:name =&gt; name}
              end
          end
=end

          if options['personality']
            data['server']['personality'] = []
            options['personality'].each do |file|
              data['server']['personality'] &lt;&lt; {
                'contents' =&gt; Base64.encode64(file['contents'] || file[:contents]),
                'path'     =&gt; file['path'] || file[:path]
              }
            end
          end

          if options['nics']
            data['server']['networks'] =
              Array(options['nics']).map do |nic|
                neti = {}
                neti['uuid'] = (nic['net_id'] || nic[:net_id]) unless (nic['net_id'] || nic[:net_id]).nil?
                neti['fixed_ip'] = (nic['v4_fixed_ip'] || nic[:v4_fixed_ip]) unless (nic['v4_fixed_ip'] || nic[:v4_fixed_ip]).nil?
                neti['port'] = (nic['port_id'] || nic[:port_id]) unless (nic['port_id'] || nic[:port_id]).nil?
                neti
              end
          end

          if options['os:scheduler_hints']
            data['os:scheduler_hints'] = options['os:scheduler_hints']
          end

          if (block_device_mapping = options['block_device_mapping_v2'])
            data['server']['block_device_mapping_v2'] = [block_device_mapping].flatten.collect do |mapping|
              entered_block_device_mapping = {}
              [:boot_index, :delete_on_termination, :destination_type, :device_name, :source_type, :uuid,
               :volume_size].each do |index|
                entered_block_device_mapping[index.to_s] = mapping[index] if mapping.key?(index)
              end
              entered_block_device_mapping
            end
          elsif (block_device_mapping = options['block_device_mapping'])
            data['server']['block_device_mapping'] = [block_device_mapping].flatten.collect do |mapping|
              {
                'delete_on_termination' =&gt; mapping[:delete_on_termination],
                'device_name'           =&gt; mapping[:device_name],
                'volume_id'             =&gt; mapping[:volume_id],
                'volume_size'           =&gt; mapping[:volume_size],
              }
            end
          end

          path = options['block_device_mapping'] ? 'os-volumes_boot.json' : 'servers.json'

          request(
            :body    =&gt; Fog::JSON.encode(data),
            :expects =&gt; [200, 202],
            :method  =&gt; 'POST',
            :path    =&gt; path
          )
        end
      end

      class Mock
        def create_server(name, image_id, flavor_id, options = {})
          response = Excon::Response.new
          response.status = 202

          server_id = Fog::Mock.random_numbers(6).to_s
	
          flavor = self.data[:flavors][flavor_id]
          image  = self.data[:images][image_id]

          mock_data = {
            'addresses'    =&gt; {"Private" =&gt; [{"addr" =&gt; Fog::Mock.random_ip}]},
#            'flavor'       =&gt; {"id" =&gt; flavor_id, "links" =&gt; [{"href" =&gt; "http://nova1:8774/admin/flavors/1", "rel" =&gt; "bookmark"}]},
            'flavor'       =&gt; Fog::Rackspace::MockData.keep(flavor, "id", "links"),
            'id'           =&gt; server_id,
#            'image'        =&gt; {"id" =&gt; image_id, "links" =&gt; [{"href" =&gt; "http://nova1:8774/admin/images/#{image_id}", "rel" =&gt; "bookmark"}]},
            'image'        =&gt; Fog::Rackspace::MockData.keep(image, "id", "links"),
#            'links'        =&gt; [{"href" =&gt; "http://nova1:8774/v1.1/admin/servers/5", "rel" =&gt; "self"}, {"href" =&gt; "http://nova1:8774/admin/servers/5", "rel" =&gt; "bookmark"}],
            'links'        =&gt; [
                                 {
                                    "href" =&gt; "https://dfw.servers.api.rackspacecloud.com/v2/010101/servers/#{server_id}",
                                    "rel" =&gt; "self",
                                 },
                                 {
                                    "href" =&gt; "https://dfw.servers.api.rackspacecloud.com/010101/servers/#{server_id}",
                                    "rel" =&gt; "bookmark",
                                 }
                              ],
            'hostId'       =&gt; "123456789ABCDEF01234567890ABCDEF",
            'name'         =&gt; name || "server_#{rand(999)}",
            'accessIPv4'   =&gt; options['accessIPv4'] || "",
            'accessIPv6'   =&gt; options['accessIPv6'] || "",
            'progress'     =&gt; 0,
            'status'       =&gt; 'BUILD',
            'created'      =&gt; '2012-09-27T00:04:18Z',
            'updated'      =&gt; '2012-09-27T00:04:27Z',
            'user_id'      =&gt; user_id,
            'config_drive' =&gt; options['config_drive'] || '',
          }

          nics = options['nics']

          if nics
            nics.each do |_nic|
              mock_data["addresses"].merge!(
                "Public" =&gt; [{'addr' =&gt; Fog::Mock.random_ip}]
              )
            end
          end

          response_data = if options['return_reservation_id'] == 'True'
                            {'reservation_id' =&gt; "r-#{Fog::Mock.random_numbers(6)}"}
                          else
                            {
                              'adminPass' =&gt; 'password',
                              'id'        =&gt; server_id,
                              'links'     =&gt; mock_data['links'],
                            }
                          end

          if block_devices = options["block_device_mapping_v2"]
            block_devices.each { |bd| volumes.get(bd[:uuid]).attach(server_id, bd[:device_name]) }
          elsif block_device = options["block_device_mapping"]
            volumes.get(block_device[:volume_id]).attach(server_id, block_device[:device_name])
          end

          data[:last_modified][:servers][server_id] = Time.now
          data[:servers][server_id] = mock_data

=begin          
          security_groups = options['security_groups']
          if security_groups
            groups = Array(security_groups).map do |sg|
              if sg.kind_of?(Fog::Compute::RackspaceV2::SecurityGroup)
                sg.name
              else
                sg
              end
            end

            data[:server_security_group_map][server_id] = groups
            response_data['security_groups'] = groups
          end
=end

          data[:last_modified][:servers][server_id] = Time.now
          data[:servers][server_id] = mock_data

          if options['os:scheduler_hints'] &amp;&amp; options['os:scheduler_hints']['group']
            group = data[:server_groups][options['os:scheduler_hints']['group']]
            group[:members] &lt;&lt; server_id if group
          end

          response.body = if options['return_reservation_id'] == 'True'
                            response_data
                          else
                            {'server' =&gt; response_data}
                          end
          response
        end


      end
    end
  end
end

