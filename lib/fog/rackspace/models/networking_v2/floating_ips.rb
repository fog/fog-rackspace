require 'fog/rackspace/models/networking_v2/network'

module Fog
  module Rackspace
    class NetworkingV2
      class FloatingIPs < Fog::Collection
        model Fog::Rackspace::NetworkingV2::FloatingIP

        def all
          data = service.list_floating_ips.body['floating_ips']
          load(data)
        end

        def get(id)
          data = service.show_floating_ips(id).body['floating_ips']
          new(data)
        rescue Fog::Rackspace::NetworkingV2::NotFound
          nil
        end
      end
    end
  end
end
