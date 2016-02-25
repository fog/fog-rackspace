# require 'spec_helper'
#
# VCR.configure do |c|
#   c.cassette_library_dir = 'spec/vcr/cloud_keep'
# end
#
# describe Fog::Rackspace::CloudKeep do
#
#   let!(:service) do
#     VCR.use_cassette('service') do
#       creds = {
#         :rackspace_api_key  => ENV['RS_API_KEY'],
#         :rackspace_username => ENV['RS_USERNAME']
#       }
#
#       Fog::Rackspace::CloudKeep.new(creds)
#     end
#   end
#
#   let(:secret_data) do
#     {
#       name: Time.now.usec.to_s,
#       algorithm: "aes",
#       bit_length: 256,
#       mode: "cbc",
#       payload: "testing!",
#       payload_content_type: "text/plain"
#     }
#   end
#
#   let!(:containers){ VCR.use_cassette('containers'){ service.containers } }
#
#   let(:container_data) do
#     {
#       type: "generic",
#       name: "container_data",
#       meta: {
#         name: "secretname",
#         algorithm: "AES",
#         bit_length: 256,
#         mode: "cbc",
#         payload_content_type: "application/octet-stream"
#       }
#     }
#   end
#
#   let(:rsa_data) do
#     {
#       name: "rsa_example",
#       type: "rsa",
#       secret_refs: [
#         {
#           name: "private_key",
#           secret_ref:"http://localhost:9311/v1/secrets/05a47308-d045-43d6-bfe3-1dbcd0c3a97b"
#         },
#         {
#           name: "public_key",
#           secret_ref:"http://localhost:9311/v1/secrets/05a47308-d045-43d6-bfe3-1dbcd0c3a97b"
#         },
#         {
#           name: "private_key_passphrase",
#           secret_ref:"http://localhost:9311/v1/secrets/05a47308-d045-43d6-bfe3-1dbcd0c3a97b"
#         }
#       ]
#     }
#   end
#
#   let(:cert_data) do
#     {
#       name: "cert_example",
#       type: "certificate",
#       secret_refs: [
#         {
#           name: "certificate",
#           secret_ref:"http://localhost:9311/v1/secrets/05a47308-d045-43d6-bfe3-1dbcd0c3a97b"
#         }
#       ]
#     }
#   end
#
#   let(:private_key) do
#     VCR.use_cassette('private_key_secret') do
#       data = secret_data.dup
#       data[:name] = 'private_key'
#       service.secrets.create(data)
#     end
#   end
#
#   let(:public_key) do
#     VCR.use_cassette('public_key_secret') do
#       data = secret_data.dup
#       data[:name] = 'public_key'
#       service.secrets.create(data)
#     end
#   end
#
#   let(:private_key_passphrase) do
#     VCR.use_cassette('private_key_passphrase') do
#       data = secret_data.dup
#       data[:name] = 'private_key_passphrase'
#       service.secrets.create(data)
#     end
#   end
#
#   let(:container) do
#     VCR.use_cassette('create_container') do
#       container_data[:type] = "rsa"
#       container = service.containers.new(container_data)
#       container.add_secret_ref(private_key)
#       container.add_secret_ref(public_key)
#       container.add_secret_ref(private_key_passphrase)
#       container.save
#       container
#     end
#   end
#
#   describe "Secret" do
#     let!(:secrets){ VCR.use_cassette('secrets'){ service.secrets } }
#
#     it "has secrets" do
#       expect(secrets).to be_kind_of Array
#     end
#
#     it "is creatable" do
#       VCR.use_cassette('create_secret') do
#         secret = service.secrets.create(secret_data)
#         expect(secret.secret_ref).not_to be_empty
#         expect(secret.id).not_to be_empty
#       end
#     end
#
#     it "is destroyable" do
#       VCR.use_cassette('destroy_secret') do
#         secret = service.secrets.create(secret_data)
#         secret.destroy
#         expect(service.secrets.get(secret.id)).to be_nil
#       end
#     end
#
#     it "is getable" do
#       VCR.use_cassette('get_secret_metadata') do
#         secret = service.secrets.create(secret_data)
#         expect(secret.status).to eq("ACTIVE") # This is set via implicit call to #refresh/metadata
#       end
#     end
#
#     it "is decryptable" do
#       VCR.use_cassette('get_secret_decrypt') do
#         secret = service.secrets.create(secret_data)
#         expect(secret.decrypt).to eq("testing!")
#       end
#     end
#   end
#
#   describe "Containers" do
#     it "is indexable" do
#       expect(containers).to be_kind_of Array
#     end
#
#     describe "validation" do
#       context "when of :rsa type" do
#         let(:container){ service.containers.new(rsa_data) }
#
#         it "requires a 'public key'" do
#           expect(container.valid?).to be_truthy
#           container.secret_refs = []
#           expect(container.valid?).to be_falsey
#           expect(container.errors).to include("RSA requires a 'public_key' secret_ref")
#         end
#
#         it "requires a 'private key'" do
#           expect(container.valid?).to be_truthy
#           container.secret_refs = []
#           expect(container.valid?).to be_falsey
#           expect(container.errors).to include("RSA requires a 'private_key' secret_ref")
#         end
#       end
#
#       context "when of :certificate type" do
#         let(:container){ service.containers.new(cert_data) }
#
#         it "requires a 'certificate'" do
#           expect(container.valid?).to be_truthy
#           container.secret_refs = []
#           expect(container.valid?).to be_falsey
#           expect(container.errors).to include("Certificate requires a 'certificate' secret_ref")
#         end
#       end
#     end
#
#     it "is creatable" do
#       expect(container.container_ref).to be_truthy
#     end
#
#     it "is getable" do
#       VCR.use_cassette('get_container') do
#         c = service.containers.get(container.id)
#         expect(c.type).to eq("rsa")
#       end
#     end
#
#     it "is indexable" do
#       VCR.use_cassette('get_containers') do
#         expect(service.containers).to be_kind_of(Array)
#       end
#     end
#   end
#
#   describe "Consumers" do
#     let(:consumer_data) do
#       {
#         "name" => "foo-service",
#         "URL" => "https://www.fooservice.com/widgets/1234"
#       }
#     end
#
#     it "is indexable" do
#       VCR.use_cassette('get_consumers') do
#         expect(service.consumers).to be_kind_of(Array)
#       end
#     end
#
#     it "is creatable" do
#       VCR.use_cassette('create_consumer') do
#         c = service.consumers.create(container.id, consumer_data)
#         expect(c.consumers).to be_kind_of(Array)
#       end
#     end
#
#     it "is destroyable" do
#       VCR.use_cassette('destroy_consumer') do
#         service.consumers.create(container.id, consumer_data)
#         before_count = service.consumers.all(container.id).size
#
#         service.consumers.destroy(container.id, consumer_data)
#         after_count = service.consumers.all(container.id).size
#
#         expect(before_count > after_count).to be_truthy
#       end
#     end
#   end
# end
