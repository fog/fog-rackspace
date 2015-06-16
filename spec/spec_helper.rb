$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'fog/rackspace'
require 'rspec'
require 'pry'
require 'vcr'
require 'fog'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
