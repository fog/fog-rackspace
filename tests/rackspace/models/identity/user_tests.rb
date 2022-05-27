Shindo.tests('Fog::Identity::Rackspace | user', ['rackspace']) do

  pending if Fog.mocking?

  service = Fog::Identity::Rackspace.new
  options = {
    :username => "fog#{Time.now.to_i.to_s}",
    :email => 'email@example.com',
    :enabled => true
  }

  model_tests(service.users, options, false) do
    tests('#save with existing user').succeeds do
      @instance.save
    end
  end
end
