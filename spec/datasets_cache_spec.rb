require 'spec_helper'

describe DatasetsCache do

  before(:each) do
    Redis.current.del('datasets')
    WebMock.stub_request(:get, "https://www.openactive.io/datasets/directory.json").to_return(body: load_fixture("directory.json"))
    WebMock.stub_request(:get, "https://api.github.com/repos/activenewham/opendata/issues").to_return(:status => 200, :body => "[]")
    WebMock.stub_request(:get, "https://api.github.com/repos/makesweat/opendata/issues").to_return(:status => 200, :body => "[]")
    WebMock.stub_request(:get, "https://activenewham-openactive.herokuapp.com/").to_return(body: load_fixture("single-item.json"))
    WebMock.stub_request(:get, "https://makesweat.com/service/openactive.php").to_return(body: load_fixture("single-item.json"))
  end

  after(:each) do
    Redis.current.del('datasets')
  end

  describe ".update" do

    it "stores datasets metadata if there were no issues making the request" do
      result = DatasetsCache.update
      not_updated = Redis.current.get('datasets').nil?

      expect(result).to be(true)
      expect(not_updated).to be(false)
      datasets = JSON.parse(Redis.current.get('datasets'))
      metadata_keys = datasets[datasets.keys.sample].keys
      expect(datasets.keys.size).to be > 0
      expect(datasets.class).to eql(Hash)
      expect(metadata_keys).to include("title", "dataset-site-url", "data-url",
        "publisher-name", "documentation-url", "license-name",
        "license-url")
    end

    it "returns false if there were issues making the request" do
      WebMock.stub_request(:get, "https://www.openactive.io/datasets/directory.json").to_return(body: "")

      result = DatasetsCache.update
      not_updated = Redis.current.get('datasets').nil?

      expect(result).to be(false)
      expect(not_updated).to be(true)
    end

    it "stores last updated timestamp when datasets are updated" do
      Redis.current.set('last_updated', 1511533639)

      result = DatasetsCache.update
      last_updated = Redis.current.get('last_updated').to_i

      expect(result).to be(true)
      expect(last_updated.class).to eql(Integer)
      expect(last_updated).to be > 1511533639
    end

    it "doesn't store last updated timestamp when datasets aren't updated" do
      Redis.current.set('last_updated', 1511533639)

      WebMock.stub_request(:get, "https://www.openactive.io/datasets/directory.json").to_return(body: "")

      result = DatasetsCache.update
      not_updated = Redis.current.get('datasets').nil?
      last_updated = Redis.current.get('last_updated').to_i

      expect(result).to be(false)
      expect(not_updated).to be(true)
      expect(last_updated).to eql(1511533639)
    end

    it "should extract dataset meta even if it couldn't page the data" do
      WebMock.stub_request(:get, "https://activenewham-openactive.herokuapp.com/").to_return(status: 500)

      result = DatasetsCache.update
      datasets = DatasetsCache.all

      expect( datasets["activenewham/opendata"] ).to include(
        "dataset-site-url", "title", "description", "publisher-name", "publisher-url",
        "keyword-1", "keyword-2", "data-url", "created", "documentation-url",
        "rpde-version", "license-name", "license-url", "attribution-text",
        "attribution-url", "mailchimp", "github-issues", "example-url"
      )
      expect( datasets["activenewham/opendata"] ).not_to include("uses-opportunity-model", "uses-paging-spec")
    end

    it "should extract dataset meta even if it couldn't reach github api" do
      WebMock.stub_request(:get, "https://api.github.com/repos/activenewham/opendata/issues").to_return(status: 500)

      result = DatasetsCache.update
      datasets = DatasetsCache.all

      expect( datasets["activenewham/opendata"] ).to include(
        "dataset-site-url", "title", "description", "publisher-name", "publisher-url",
        "keyword-1", "keyword-2", "data-url", "created", "documentation-url",
        "rpde-version", "license-name", "license-url", "attribution-text",
        "attribution-url", "mailchimp", "uses-opportunity-model", "uses-paging-spec",
        "example-url")

      expect( datasets["activenewham/opendata"] ).not_to include("github-issues")
    end

  end

  describe ".last_updated" do
    it "retrieves stored timestamp as a time object" do
      Redis.current.set('last_updated', Time.now.to_i)
      expect(DatasetsCache.last_updated.class).to eql(Time)
    end

    it "returns nil if nothing stored for last_updated" do
      Redis.current.del('last_updated')
      expect(DatasetsCache.last_updated).to eql(nil)
    end
  end

  describe ".needs_update?" do
    it "returns true if last updated was nil" do
      Redis.current.del('last_updated')
      expect(DatasetsCache.needs_update?).to eql(true)
    end

    it "returns true if last updated was more than 30 minutes ago" do
      forty_minutes_ago = Time.now - 40*60
      Redis.current.set("last_updated", forty_minutes_ago.to_i)
      expect(DatasetsCache.needs_update?).to eql(true)
    end

    it "returns false if last updated was after 30 minutes ago" do
      twenty_minutes_ago = Time.now - 20*60
      Redis.current.set("last_updated", twenty_minutes_ago.to_i)
      expect(DatasetsCache.needs_update?).to eql(false)
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
    end
  end

end