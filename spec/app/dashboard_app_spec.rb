require 'spec_helper'
require_relative '../../dashboard_app'

describe DashboardApp do

  def app
    DashboardApp
  end

  before(:each) do
    Redis.current.del('datasets')
    Redis.current.hdel("activenewham/opendata", "last_page")
    Redis.current.zremrangebyrank("activenewham/opendata/activities", 0, -1)

    WebMock.stub_request(:get, "https://api.github.com/repos/activenewham/opendata/issues").to_return(:status => 200, :body => "[]")
    WebMock.stub_request(:get, "https://api.github.com/repos/makesweat/opendata/issues").to_return(:status => 200, :body => "[]")
    WebMock.stub_request(:get, "https://www.openactive.io/datasets/directory.json").to_return(body: load_fixture("directory.json"))
    WebMock.stub_request(:get, "https://activenewham-openactive.herokuapp.com").to_return(body: load_fixture("single-item.json"))
    WebMock.stub_request(:get, "https://makesweat.com/service/openactive.php").to_return(body: load_fixture("single-item.json"))

    WebMock.stub_request(:get, "http://www.example.com").to_return(body: load_fixture("single-item.json"))
    WebMock.stub_request(:get, "http://www.example.com/next").to_return(body: load_fixture("multiple-items.json"))
    WebMock.stub_request(:get, "http://www.example.com/last").to_return(body: load_fixture("last-page.json"))

    DatasetsCache.update
    AvailabilityCache.update
  end

  it "includes google analytics code from environment variable" do
    ENV["GOOGLE_ANALYTICS_CODE"] = 'UA-XYZXYZ-Y'
    get "/"
    ga_code_setup = "ga('create', 'UA-XYZXYZ-Y', 'auto');"
    expect(last_response.status).to eq 200
    expect(last_response.body).to include(ga_code_setup)
  end

  it "returns a static style test page" do
    get "/test"
    expect(last_response.status).to eq 200
  end

  it "returns a json file with appropriate metadata" do
    get "/datasets.json"
    result = JSON.parse(last_response.body)
    expect(result.keys).to include("meta", "data")
    expect(result["meta"].keys).to include("last-updated", "licence")
    expect(result["data"].keys.size).to eql(2)
    expect(result["data"]["activenewham/opendata"]).to include("dataset-site-url", "title", "description", "publisher-name", 
      "publisher-url", "data-url", "documentation-url", "license-name", 
      "license-url", "attribution-text", "attribution-url", "available",
      "uses-paging-spec", "uses-opportunity-model", "github-issues")
    expect(result["data"]["activenewham/opendata"]).not_to include('mailchimp', 'keyword-1', 'keyword-2', 'created', 'rpde-version', 
      'copyright-notice', 'odi-certificate-number', 'publish')
  end

  it "returns a dataset summary" do
    DatasetSummary.new('activenewham/opendata').harvest
    get "/summary/activenewham/opendata"
    expect(last_response.body).to include("<td>body attack</td>")
  end

end