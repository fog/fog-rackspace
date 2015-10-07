require "minitest/autorun"
require "fog-rackspace"
require "fog/rackspace/bin"
require "helpers/bin"

describe Rackspace do
  include Fog::BinSpec

  let(:subject) { Rackspace }
end
