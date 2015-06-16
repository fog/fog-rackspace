require 'spec_helper'
require "minitest/autorun"
require "fog"
require "fog/bin"
# require "helpers/bin"

describe Fog::Rackspace do
  # include Fog::BinSpec
  # let(:subject) { Rackspace }

  it 'has a version number' do
    expect(Fog::Rackspace::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
