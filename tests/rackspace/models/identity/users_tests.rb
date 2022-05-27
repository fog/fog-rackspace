Shindo.tests('Fog::Identity::Rackspace | users', ['rackspace']) do

  pending if Fog.mocking?

  service = Fog::Identity::Rackspace.new
  username = "fog#{Time.now.to_i.to_s}"
  options = {
    :username => username,
    :email => 'email@example.com',
    :enabled => true
  }
  collection_tests(service.users, options, false) do
    tests('#get_by_name').succeeds do
      service.users.get_by_name(username)
    end
  end
end
