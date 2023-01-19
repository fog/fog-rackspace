module Fog
  module Rackspace
    class Storage
      class Real
        # List existing storage containers
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'limit'<~Integer> - Upper limit to number of results returned
        #   * 'marker'<~String> - Only return objects with name greater than this value
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * container<~Hash>:
        #       * 'bytes'<~Integer>: - Number of bytes used by container
        #       * 'count'<~Integer>: - Number of items in container
        #       * 'name'<~String>: - Name of container
        # @raise [Fog::Rackspace::Storage::NotFound] - HTTP 404
        # @raise [Fog::Rackspace::Storage::BadRequest] - HTTP 400
        # @raise [Fog::Rackspace::Storage::InternalServerError] - HTTP 500
        # @raise [Fog::Rackspace::Storage::ServiceError]
        def get_containers(options = {})
          options = options.reject {|key, value| value.nil?}
          request(
            :expects  => [200, 204],
            :method   => 'GET',
            :path     => '',
            :query    => {'format' => 'json'}.merge!(options)
          )
        end
      end

      class Mock
        def get_containers(options = {})
          results = data.map do |name, container|
            {
              "name" => name,
              "count" => container.objects.size,
              "bytes" => container.bytes_used
            }
          end
          response = Excon::Response.new
          response.status = 200
          response.body = results
          response
        end
      end
    end
  end
end
