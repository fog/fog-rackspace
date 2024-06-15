module Fog
  module Rackspace
    class Storage
      module Common
        # Get an expiring object http url from Cloud Files
        #
        # ==== Parameters
        # * container<~String> - Name of container containing object
        # * object<~String> - Name of object to get expiring url for
        # * expires<~Time> - An expiry time for this url
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~String> - url for object
        # @raise [Fog::Rackspace::Storage::NotFound] - HTTP 404
        # @raise [Fog::Rackspace::Storage::BadRequest] - HTTP 400
        # @raise [Fog::Rackspace::Storage::InternalServerError] - HTTP 500
        # @raise [Fog::Rackspace::Storage::ServiceError]
        # ==== See Also
        # http://docs.rackspace.com/files/api/v1/cf-devguide/content/Create_TempURL-d1a444.html
        def get_object_http_url(container, object, expires, options = {})
          get_object_https_url(container, object, expires, options.merge(:scheme => 'http'))
        end
      end

      class Real
        include Common
      end

      class Mock
        include Common
      end
    end
  end
end
