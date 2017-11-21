require 'spec_helper'

describe DatasetsCache do

  describe ".update" do
    it "stores datasets metadata if there were no issues making the request" do
      Redis.current.del('datasets')

      result = DatasetsCache.update
      not_updated = Redis.current.get('datasets').nil?

      expect(result).to be(true).or be(false)

      if result
        expect(not_updated).to be(false)
        datasets = JSON.parse(Redis.current.get('datasets'))
        metadata_keys = datasets[datasets.keys.sample].keys
        expect(datasets.keys.size).to be > 0
        expect(datasets.class).to eql(Hash)
        expect(metadata_keys).to include("title", "dataset-site-url", "data-url", 
          "publisher-name", "documentation-url", "license-name", 
          "license-url")
      else
        puts "Datasets cache was not updated"
        expect(not_updated).to be(true)
      end

      Redis.current.del('datasets')
    end
  end

  describe ".all" do
    it "retrieves a collection of datasets" do
      example = { "mywebsait/opendata" => { "title" => "my dataset title", "data-url" => "http://mywebsait.com/data" } }
      Redis.current.set('datasets', example.to_json)

      datasets = DatasetsCache.all
      expect(datasets.class).to eql(Hash)
      expect(datasets.keys.size).to be > 0
      expect(datasets["mywebsait/opendata"].class).to eql(Hash)
      expect(datasets["mywebsait/opendata"].keys).to include("title", "data-url")

      Redis.current.del('datasets')
    end
  end

end