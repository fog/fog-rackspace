module Fog
  module Rackspace
    class NetworkingV2
      class FloatingIP < Fog::Model

        identity :id

        attribute :status
        attribute :router_id
        attribute :tenant_id
        attribute :floating_network_id
        attribute :fixed_ip_address
        attribute :floating_ip_address
        attribute :port_id

        def save
          data = unless self.id.nil?
            service.update_floating_ip(self)
          else
            service.create_floating_ip(self)
          end

          merge_attributes(data.body['floating_ip'])
          true
        end

        def destroy
          requires :identity

          service.delete_floating_ip(identity)
          true
        end
      end
    end
  end
end
