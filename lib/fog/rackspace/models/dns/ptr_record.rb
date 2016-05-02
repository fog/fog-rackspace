require 'fog/core/model'

module Fog
  module DNS
    class Rackspace
      class PtrRecord < Fog::Model
        attribute :link
        attribute :records

        def set_target(obj, content="")
          self.link = { rel: '', content: content }

          if obj.is_a?(Fog::Compute::RackspaceV2::Server)
            self.link[:rel] = "cloudServersOpenStack"
            self.link[:href] = obj.links[0]['href']
          elsif obj.is_a?(Fog::Rackspace::LoadBalancers::LoadBalancer)
            self.link[:rel] = "cloudLoadBalancerOpenStack"
          else
            raise "Need either a cloud server or a load balancer to target."
          end

          self.link
        end

        def add_record(record_data)
          raise "Need name" unless record_data.name.present?
          raise "Need data" unless record_data.data.present?
          raise "Need ttl" unless record_data.ttl.present?
          raise "Need type" unless record_data.type.present?
          self.records << record_data
        end

        def to_hash
          record_list = { records: self.records }
          { link: self.link, recordsList: record_list }
        end
      end
    end
  end
end


# {
#   "link": {
#     "content": "",
#     "href": "https://iad.servers.api.rackspacecloud.com/v2/930035/servers/917185a6-ea7c-4bae-8954-f58b39b8b7f2",
#     "rel": "cloudServersOpenStack"
#   },
#   "recordsList": {
#     "records": [
#       {
#         "data": "104.239.229.156",
#         "name": "example.com",
#         "ttl": 56000,
#         "type": "PTR"
#       }
#     ]
#   }
# }
