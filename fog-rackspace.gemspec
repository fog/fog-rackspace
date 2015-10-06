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
  spec.homepage      = 'https://github.com/fog/fog-rackspace'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(tests|spec)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

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
