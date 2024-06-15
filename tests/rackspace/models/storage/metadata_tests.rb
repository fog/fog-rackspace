require 'fog/rackspace/models/storage/metadata'
require 'fog/rackspace/models/storage/directory'
require 'fog/rackspace/models/storage/directories'
require 'fog/rackspace/models/storage/file'

Shindo.tests('Fog::Rackspace::Storage | metadata', ['rackspace']) do

  def assert_directory(obj, assert_value)
    metadata = Fog::Rackspace::Storage::Metadata.new obj
    returns(assert_value) { metadata.send :directory? }
  end

  def assert_file(obj, assert_value)
    metadata = Fog::Rackspace::Storage::Metadata.new obj
    returns(assert_value) { metadata.send :file? }
  end

  tests('Directory') do
    @directory = Fog::Rackspace::Storage::Directory.new
    tests('#to_key') do
      tests('valid key').returns(:image_size) do
        metadata = Fog::Rackspace::Storage::Metadata.new @directory
        metadata.send(:to_key, "X-Container-Meta-Image-Size")
      end
      tests('invalid key').returns(nil) do
        metadata = Fog::Rackspace::Storage::Metadata.new @directory
        metadata.send(:to_key, "bad-key")
      end
    end

    tests('#[]') do
      tests('[:symbol_test]=42') do
        metadata = Fog::Rackspace::Storage::Metadata.new @directory

        metadata[:symbol_test] = 42
        returns(42) { metadata[:symbol_test] }
        returns(42) { metadata['symbol_test'] }
        returns(nil) { metadata[:nil_test] }
      end

      tests('[\'string_test\']=55') do
        metadata = Fog::Rackspace::Storage::Metadata.new @directory

        metadata['string_test'] = 55
        returns(55) { metadata[:string_test] }
        returns(55) { metadata['string_test'] }
        returns(nil) { metadata['nil_test'] }
      end

      tests('set string and symbol') do
        metadata = Fog::Rackspace::Storage::Metadata.new @directory

        metadata[:key_test] = 55
        metadata['key_test'] = 55
        returns(1) { metadata.size }
      end

      tests('key to remove').returns("X-Remove-Container-Meta-Thumbnail-Image") do
        metadata = Fog::Rackspace::Storage::Metadata.new @directory

        metadata.send(:to_header_key, :thumbnail_image, nil)
      end
    end


    tests('#to_header_key') do
      metadata = Fog::Rackspace::Storage::Metadata.new @directory

      tests('key to add').returns("X-Container-Meta-Thumbnail-Image") do
        metadata.send(:to_header_key, :thumbnail_image, true)
      end

      tests('key to remove').returns("X-Remove-Container-Meta-Thumbnail-Image") do
        metadata.send(:to_header_key, :thumbnail_image, nil)
      end
    end

    tests('#to_headers').returns({"X-Container-Meta-Preview"=>true, "X-Remove-Container-Meta-Delete-Me"=>1}) do
      metadata = Fog::Rackspace::Storage::Metadata.new @directory
      metadata[:preview] = true
      metadata[:delete_me] = nil

      metadata.to_headers
    end

  tests("#from_headers").returns({:my_boolean=>"true", :my_integer=>"42", :my_string=>"I am a string"}) do
    headers = {
      "X-Container-Meta-My-Integer"=> "42",
      "X-Container-Meta-My-Boolean"=> "true",
      "X-Container-Meta-My-String"=> "I am a string"
    }

      metadata = Fog::Rackspace::Storage::Metadata.from_headers @directory, headers
      metadata.data
    end

     tests("#delete").returns({"X-Remove-Container-Meta-Delete-Me"=>1}) do
       metadata = Fog::Rackspace::Storage::Metadata.new @directory
        metadata.delete(:delete_me)

        metadata.to_headers
     end
   end

   tests('File') do
     @file = Fog::Rackspace::Storage::File.new
     tests('#to_key') do
       tests('valid key').returns(:image_size) do
         metadata = Fog::Rackspace::Storage::Metadata.new @file
         metadata.send(:to_key, "X-Object-Meta-Image-Size")
       end
       tests('invalid key').returns(nil) do
         metadata = Fog::Rackspace::Storage::Metadata.new @file
         metadata.send(:to_key, "bad-key")
       end
     end

     tests('#to_header_key') do
       metadata = Fog::Rackspace::Storage::Metadata.new @file

       tests('key to add').returns("X-Object-Meta-Thumbnail-Image") do
         metadata.send(:to_header_key, :thumbnail_image, true)
       end

       tests('key to remove').returns("X-Remove-Object-Meta-Thumbnail-Image") do
         metadata.send(:to_header_key, :thumbnail_image, nil)
       end
     end

     tests('#to_headers').returns({"X-Object-Meta-Preview"=>true, "X-Remove-Object-Meta-Delete-Me"=>1}) do
       metadata = Fog::Rackspace::Storage::Metadata.new @file
       metadata[:preview] = true
       metadata[:delete_me] = nil

       metadata.to_headers
     end

     tests("#from_headers").returns({:my_boolean=>"true", :my_integer=>"42", :my_string=>"I am a string"}) do
       headers = {
         "X-Object-Meta-My-Integer"=> "42",
         "X-Object-Meta-My-Boolean"=> "true",
         "X-Object-Meta-My-String"=> "I am a string"
       }

       metadata = Fog::Rackspace::Storage::Metadata.from_headers @file, headers
       metadata.data
     end

      tests("#delete").returns({"X-Remove-Object-Meta-Delete-Me"=>1}) do
        metadata = Fog::Rackspace::Storage::Metadata.new @file
         metadata.delete(:delete_me)

         metadata.to_headers
      end
    end

   tests("#respond_to?") do
     tests('Should respond to all of the methods in Hash class').returns(true) do
       metadata = Fog::Rackspace::Storage::Metadata.new @file
       Hash.instance_methods.all? {|method| metadata.respond_to?(method)}
     end
     tests('Should respond to all of the methods in the Metadata class').returns(true) do
       metadata = Fog::Rackspace::Storage::Metadata.new @file
       metadata.methods.all? {|method| metadata.respond_to?(method)}
     end
   end

   tests("#method_missing").returns(true) do
     metadata = Fog::Rackspace::Storage::Metadata.new @file
      metadata[:test] = true
      metadata[:test]
   end

   tests('#directory?') do
     assert_directory Fog::Rackspace::Storage::Directories, true
     assert_directory Fog::Rackspace::Storage::Directory, true
     assert_directory Fog::Rackspace::Storage::Directory.new, true

     assert_directory nil, false
     assert_directory Fog::Rackspace::Storage::Files, false
     assert_directory Fog::Rackspace::Storage::File, false
     assert_directory Fog::Rackspace::Storage::File.new, false
     assert_directory "I am a string!", false
   end

   tests('#file?') do
     assert_file Fog::Rackspace::Storage::Directories, false
     assert_file Fog::Rackspace::Storage::Directory, false
     assert_file Fog::Rackspace::Storage::Directory.new, false

     assert_file nil, false
     assert_file Fog::Rackspace::Storage::Files, true
     assert_file Fog::Rackspace::Storage::File, true
     assert_file Fog::Rackspace::Storage::File.new, true
     assert_file "I am a string!", false
   end

   tests('#parent_class') do
     tests('Fog::Rackspace::Storage::Directory object') do
       metadata = Fog::Rackspace::Storage::Metadata.new Fog::Rackspace::Storage::Directory.new
       returns(Fog::Rackspace::Storage::Directory) { metadata.send :parent_class }
     end
     tests('Fog::Rackspace::Storage::Directory class') do
       metadata = Fog::Rackspace::Storage::Metadata.new Fog::Rackspace::Storage::Directory
       returns(Fog::Rackspace::Storage::Directory) { metadata.send :parent_class }
     end
   end
end
