require "bundler/gem_tasks"
require 'rake/testtask'
require 'rubygems'

Rake::TestTask.new do |t|
  t.pattern = File.join("spec", "**", "*_spec.rb")
  t.libs << "spec"
end

task :default => :test

namespace :test do
  mock = ENV['FOG_MOCK'] || 'true'
  task :rackspace do
    sh("export FOG_MOCK=#{mock} && bundle exec shindont tests/rackspace")
  end
end

desc 'Run mocked tests for a specific provider'
task :mock, :provider do |t, args|
  if args.to_a.size != 1
    fail 'USAGE: rake mock[<provider>]'
  end
  provider = args[:provider]
  sh("export FOG_MOCK=true && bundle exec shindont tests/#{provider}")
end

desc 'Run live tests against a specific provider'
task :live, :provider do |t, args|
  if args.to_a.size != 1
    fail 'USAGE: rake live[<provider>]'
  end
  provider = args[:provider]
  sh("export FOG_MOCK=false PROVIDER=#{provider} && bundle exec shindont tests/#{provider}")
end

task :nuke do
  require 'bundler/setup'
  require 'fog/rackspace/core'
  require 'fog/rackspace/bin'
  Fog.available_providers.each do |provider|
    next if ['Vmfusion'].include?(provider)
    begin
      compute = Fog::Compute.new(:provider => provider)
      for server in compute.servers
        Fog::Formatador.display_line("[#{provider}] destroying server #{server.identity}")
        server.destroy rescue nil
      end
    rescue
    end

    begin
      dns = Fog::DNS.new(:provider => provider)
      for zone in dns.zones
        for record in zone.records
          record.destroy rescue nil
        end
        Fog::Formatador.display_line("[#{provider}] destroying zone #{zone.identity}")
        zone.destroy rescue nil
      end
    rescue
    end
  end
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/#{name}.rb"
end