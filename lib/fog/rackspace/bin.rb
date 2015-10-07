require 'fog/core/credentials'
require 'fog/rackspace/core'

module Fog
  class << self
    def available_providers
      @available_providers ||= Fog.providers.values.select {|provider| Kernel.const_get(provider).available?}.sort
    end

    def registered_providers
      @registered_providers ||= Fog.providers.values.sort
    end
  end

  class Bin
    class << self
      def available?
        availability = true
        for service in services
          begin
            service = self.class_for(service)
            availability &&= service.requirements.all? { |requirement| Fog.credentials.include?(requirement) }
          rescue ArgumentError => e
            Fog::Logger.warning(e.message)
            availability = false
          rescue => e
            availability = false
          end
        end

        if availability
          for service in services
            for collection in self.class_for(service).collections
              unless self.respond_to?(collection)
                self.class_eval <<-EOS, __FILE__, __LINE__
                  def self.#{collection}
                    self[:#{service}].#{collection}
                  end
                EOS
              end
            end
          end
        end

        availability
      end

      def collections
        services.map {|service| self[service].collections}.flatten.sort_by {|service| service.to_s}
      end
    end
  end
end

require 'fog/bin/rackspace'