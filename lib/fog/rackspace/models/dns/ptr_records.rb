require 'fog/core/collection'
require 'fog/rackspace/models/dns/record'

module Fog
  module DNS
    class Rackspace
      class PtrRecords < Fog::Collection
        model Fog::DNS::Rackspace::PtrRecord

        def all
          data = service.list_ptr_records
          load(data.body['recordsList'])
        end

        alias_method :each_record_this_page, :each
        def each
          requires :zone

          return self unless block_given?

          entries = 0
          begin
            body = service.list_ptr_records(zone.id, :offset => entries).body
            entries += body['recordsList'].size

            self.merge_attributes(body)

            subset = dup.load(body['recordsList'])
            subset.each_record_this_page {|record| yield record }

          end while entries < total_entries

          self
        end

        def get(record_id)
          requires :zone
          data = service.list_ptr_record_details(zone.identity, record_id).body
          new(data)
        #nil or empty string will trigger an argument error
        rescue ArgumentError
          nil
        rescue Fog::DNS::Rackspace::NotFound
          nil
        end

        def new(attributes = {})
          requires :zone
          super({ :zone => zone }.merge!(attributes))
        end
      end
    end
  end
end
