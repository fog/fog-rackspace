# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fog/rackspace/version'

Gem::Specification.new do |spec|
  spec.name          = 'fog-rackspace'
  spec.version       = Fog::Rackspace::VERSION
  spec.authors       = ['Matt Darby']
  spec.email         = ['matt.darby@rackspace.com']

  spec.summary       = 'Rackspace provider gem for Fog'
  spec.description   = 'Rackspace provider gem for Fog ecosystem'
  spec.homepage      = 'http://github.com/rackerlabs/fog-rackspace'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    fail 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(tests|spec)/}) }
  spec.test_files    = `git ls-files -- {spec,tests}/*`.split("\x0")
  spec.require_paths = ['lib']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.add_dependency 'fog-core'
  spec.add_dependency 'fog-json'

  spec.add_dependency "ipaddress", '~> 0.5'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-stub-const'
  spec.add_development_dependency 'shindo', '~> 0.3.4'
  spec.add_development_dependency "rspec-core"
  spec.add_development_dependency "rspec-expectations"
end
