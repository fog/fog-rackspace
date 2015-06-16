require 'fog/core'
require 'fog/bin'
require 'fog'
require 'fog/json'

require_relative 'rackspace/version'
require_relative 'rackspace/core'
require_relative 'rackspace/auto_scale'
require_relative 'rackspace/block_storage'
require_relative 'rackspace/cdn'
require_relative 'rackspace/cdn_v2'
require_relative 'rackspace/compute'
require_relative 'rackspace/compute_v2'
require_relative 'rackspace/databases'
require_relative 'rackspace/dns'
require_relative 'rackspace/identity'
require_relative 'rackspace/load_balancers'
require_relative 'rackspace/monitoring'
require_relative 'rackspace/queues'
require_relative 'rackspace/storage'
require_relative 'rackspace/networking'
require_relative 'rackspace/orchestration'
require_relative 'rackspace/networking_v2'

class Rackspace < Fog::Bin
  class << self
    def class_for(key)
      case key
      when :auto_scale
        Fog::Rackspace::AutoScale
      when :block_storage
        Fog::Rackspace::BlockStorage
      when :cdn
        Fog::CDN::Rackspace
      when :cdn_v2
        Fog::Rackspace::CDNV2
      when :compute
        Fog::Compute::Rackspace
      when :compute_v2
        Fog::Compute::RackspaceV2
      when :storage
        Fog::Storage::Rackspace
      when :load_balancers
        Fog::Rackspace::LoadBalancers
      when :dns
        Fog::DNS::Rackspace
      when :identity
        Fog::Rackspace::Identity
      when :databases
        Fog::Rackspace::Databases
      when :monitoring
        Fog::Rackspace::Monitoring
      when :queues
        Fog::Rackspace::Queues
      when :networking
        Fog::Rackspace::Networking
      when :networking_v2
        Fog::Rackspace::NetworkingV2
      else
        fail ArgumentError, "Unrecognized service: #{key}"
      end
    end

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
                    when :auto_scale
                      Fog::Rackspace::AutoScale.new
                    when :cdn
                      Fog::Logger.warning('Rackspace[:cdn] is not recommended, use CDN[:rackspace] for portability')
                      Fog::CDN.new(provider: 'Rackspace')
                    when :cdn_v2
                      Fog::Rackspace::CDNV2.new
                    when :compute
                      Fog::Logger.warning('Rackspace[:compute] is not recommended, use Compute[:rackspace] for portability')
                      Fog::Compute.new(provider: 'Rackspace')
                    when :compute_v2
                      Fog::Logger.warning('Rackspace[:compute] is not recommended, use Compute[:rackspace] for portability')
                      Fog::Compute.new(provider: 'Rackspace', version: 'v2')
                    when :dns
                      Fog::DNS.new(provider: 'Rackspace')
                    when :load_balancers
                      Fog::Rackspace::LoadBalancers.new
                    when :storage
                      Fog::Logger.warning('Rackspace[:storage] is not recommended, use Storage[:rackspace] for portability')
                      Fog::Storage.new(provider: 'Rackspace')
                    when :identity
                      Fog::Logger.warning('Rackspace[:identity] is not recommended, use Identity[:rackspace] for portability')
                      Fog::Identity.new(provider: 'Rackspace')
                    when :databases
                      Fog::Rackspace::Databases.new
                    when :block_storage
                      Fog::Rackspace::BlockStorage.new
                    when :monitoring
                      Fog::Rackspace::Monitoring.new
                    when :queues
                      Fog::Rackspace::Queues.new
                    when :networking
                      Fog::Rackspace::Networking.new
                    when :networking_v2
                      Fog::Rackspace::NetworkingV2.new
                    else
                      fail ArgumentError, "Unrecognized service: #{key.inspect}"
        end
      end
      @@connections[service]
    end

    def services
      Fog::Rackspace.services
    end
  end
end
