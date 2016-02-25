$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'fog/rackspace'
require 'rspec'
require 'pry'
require 'vcr'

vcr_filters = %w{RS_API_KEY RS_USERNAME RS_TENANT_ID}
vcr_filters.each{ |env_var| raise "MISSING VCR SENSITIVE DATA ENV VAR: #{env_var}" unless ENV[env_var] }

VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr"
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = { :record => :new_episodes }
  c.filter_sensitive_data('<RS_API_KEY>') { ENV['RS_API_KEY'] }
  c.filter_sensitive_data('<RS_USERNAME>') { ENV['RS_USERNAME'] }
  c.filter_sensitive_data('<RS_TENANT_ID>') { ENV['RS_TENANT_ID'] }
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
