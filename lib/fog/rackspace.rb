require 'fog/core'
require 'fog/bin'
require 'fog/json'

require File.expand_path('../rackspace/version', __FILE__)
require File.expand_path('../rackspace/service', __FILE__)

module Fog
  module CDN
    autoload :Rackspace, File.expand_path('../rackspace/cdn', __FILE__)
    autoload :Rackspace, File.expand_path('../rackspace/cdn_v2', __FILE__)
  end

  module Compute
    autoload :Rackspace, File.expand_path('../rackspace/compute', __FILE__)
    autoload :Rackspace, File.expand_path('../rackspace/compute_v2', __FILE__)
  end

  module DNS
    autoload :Rackspace, File.expand_path('../rackspace/dns', __FILE__)
  end

  module Storage
    autoload :Rackspace, File.expand_path('../rackspace/storage', __FILE__)
  end

  module Rackspace
    extend Fog::Provider

    autoload :Errors, File.expand_path('../rackspace/errors', __FILE__)
    autoload :Mock, File.expand_path('../rackspace/mock_data', __FILE__)

    autoload :AutoScale, File.expand_path('../rackspace/auto_scale', __FILE__)
    autoload :BlockStorage, File.expand_path('../rackspace/block_storage', __FILE__)
    autoload :CDN, File.expand_path('../rackspace/cdn', __FILE__)
    autoload :CDNV2, File.expand_path('../rackspace/cdn_v2', __FILE__)
    autoload :Compute, File.expand_path('../rackspace/compute', __FILE__)
    autoload :ComputeV2, File.expand_path('../rackspace/compute_v2', __FILE__)
    autoload :DNS, File.expand_path('../rackspace/dns', __FILE__)
    autoload :Storage, File.expand_path('../rackspace/storage', __FILE__)
    autoload :LoadBalancers, File.expand_path('../rackspace/load_balancers', __FILE__)
    autoload :Identity, File.expand_path('../rackspace/identity', __FILE__)
    autoload :Databases, File.expand_path('../rackspace/databases', __FILE__)
    autoload :Monitoring, File.expand_path('../rackspace/monitoring', __FILE__)
    autoload :Queues, File.expand_path('../rackspace/queues', __FILE__)
    autoload :Networking, File.expand_path('../rackspace/networking', __FILE__)
    autoload :NetworkingV2, File.expand_path('../rackspace/networking_v2', __FILE__)
    autoload :Orchestration, File.expand_path('../rackspace/orchestration', __FILE__)

    service(:auto_scale,       'AutoScale')
    service(:block_storage,    'BlockStorage')
    service(:cdn,              'CDN')
    service(:cdn_v2,           'CDN v2')
    service(:compute,          'Compute')
    service(:compute_v2,       'Compute v2')
    service(:dns,              'DNS')
    service(:storage,          'Storage')
    service(:load_balancers,   'LoadBalancers')
    service(:identity,         'Identity')
    service(:databases,        'Databases')
    service(:monitoring,       'Monitoring')
    service(:queues,           'Queues')
    service(:networking,       'Networking')
    service(:orchestration,    'Orchestration')
    service(:networkingV2,     'NetworkingV2')
  end
end

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
