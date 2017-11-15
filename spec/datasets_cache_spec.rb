require 'spec_helper'

describe DatasetsCache do

  describe ".update" do
    it "it stores result of the request if there were no issues" do
      Redis.current.del('datasets')
      
      result = DatasetsCache.update
      not_updated = Redis.current.get('datasets').nil?

      expect(result).to be(true).or be(false)

      if result
        expect(not_updated).to be(false)
      else
        expect(not_updated).to be(true)
      end
    end
  end

  describe ".all" do
    it "retrieves a collection of datasets" do
      example = [{ "id" => "1", "title" => "my dataset title", "data_url" => "http://mywebsait.com/data" }]
      Redis.current.set('datasets', example.to_json)

      datasets = DatasetsCache.all
      expect(datasets.class).to eql(Array)
      expect(datasets.size).to be > 0
      expect(datasets[0].class).to eql(Hash)
      expect(datasets[0].keys).to include("id", "title", "data_url")
    end
  end

end