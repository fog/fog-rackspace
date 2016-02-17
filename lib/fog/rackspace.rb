require "fog/rackspace/version"

require 'fog/core'
require 'fog/json'
require 'fog/rackspace/mock_data'
require 'fog/rackspace/service'
require 'fog/rackspace/errors'
require 'fog/rackspace/auto_scale'
require 'fog/rackspace/block_storage'
require 'fog/rackspace/cdn'
require 'fog/rackspace/cdn_v2'
require 'fog/rackspace/compute'
require 'fog/rackspace/compute_v2'
require 'fog/rackspace/databases'
require 'fog/rackspace/dns'
require 'fog/rackspace/identity'
require 'fog/rackspace/load_balancers'
require 'fog/rackspace/monitoring'
require 'fog/rackspace/queues'
require 'fog/rackspace/storage'
require 'fog/rackspace/networking'
require 'fog/rackspace/orchestration'
require 'fog/rackspace/networking_v2'

module Fog
  module Rackspace
    extend Fog::Provider

    US_AUTH_ENDPOINT = 'https://identity.api.rackspacecloud.com/v2.0' unless defined? US_AUTH_ENDPOINT
    UK_AUTH_ENDPOINT = 'https://lon.identity.api.rackspacecloud.com/v2.0' unless defined? UK_AUTH_ENDPOINT

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

    def self.authenticate(options, connection_options = {})
      rackspace_auth_url = options[:rackspace_auth_url]
      rackspace_auth_url ||= options[:rackspace_endpoint] == Fog::Compute::RackspaceV2::LON_ENDPOINT ? UK_AUTH_ENDPOINT : US_AUTH_ENDPOINT
      url = rackspace_auth_url.match(/^https?:/) ? \
                rackspace_auth_url : 'https://' + rackspace_auth_url
      uri = URI.parse(url)
      connection = Fog::Core::Connection.new(url, false, connection_options)
      @rackspace_api_key  = options[:rackspace_api_key]
      @rackspace_username = options[:rackspace_username]
      response = connection.request({
        :expects  => [200, 204],
        :headers  => {
          'X-Auth-Key'  => @rackspace_api_key,
          'X-Auth-User' => @rackspace_username
        },
        :method   => 'GET',
        :path     =>  (uri.path and not uri.path.empty?) ? uri.path : 'v1.0'
      })
      response.headers.reject do |key, value|
        !['X-Server-Management-Url', 'X-Storage-Url', 'X-CDN-Management-Url', 'X-Auth-Token'].include?(key)
      end
    end

    def self.json_response?(response)
      return false unless response && response.headers
      response.get_header('Content-Type') =~ %r{application/json}i ? true : false
    end

    def self.normalize_url(endpoint)
      return nil unless endpoint
      str = endpoint.chomp " "
      str = str.chomp "/"
      str.downcase
    end

    # CGI.escape, but without special treatment on spaces
    def self.escape(str,extra_exclude_chars = '')
      # '-' is a special character inside a regex class so it must be first or last.
      # Add extra excludes before the final '-' so it always remains trailing, otherwise
      # an unwanted range is created by mistake.
      str.gsub(/([^a-zA-Z0-9_.#{extra_exclude_chars}-]+)/) do
        '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
      end
    end
  end
end
