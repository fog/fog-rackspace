require 'fog'
require_relative 'lib/fog/rackspace'

Fog::Rackspace::AutoScale.new
puts '[x] AutoScale'

Fog::CDN::Rackspace.new
puts '[x] CDNV1'

Fog::Rackspace::CDNV2.new
puts '[x] CDNV2'

# Fog::Compute::Rackspace.new
# puts '[x] ComputeV1'

Fog::Compute::RackspaceV2.new
puts '[x] ComputeV2'

Fog::DNS::Rackspace.new
puts '[x] DNS'

Fog::Rackspace::LoadBalancers.new
puts '[x] LoadBalancer'

Fog::Storage::Rackspace.new
puts '[x] Storage'

Fog::Rackspace::Identity.new
puts '[x] Identity'

Fog::Rackspace::Databases.new
puts '[x] Database'

Fog::Rackspace::BlockStorage.new
puts '[x] BlockStorage'

Fog::Rackspace::Monitoring.new
puts '[x] Monitoring'

Fog::Rackspace::Queues.new
puts '[x] Queue'

Fog::Rackspace::Networking.new
puts '[x] NetworkingV1'

Fog::Rackspace::NetworkingV2.new
puts '[x] NetworkingV2'
