Shindo.tests('Fog::Identity::Rackspace | roles', ['rackspace']) do

  pending if Fog.mocking?

  service = Fog::Identity::Rackspace.new
  user = service.users.all.first

  tests("#all").succeeds do
    user.roles.all
  end

  tests("#get").succeeds do
    role = user.roles.all.first
    user.roles.get(role.identity)
  end
end
