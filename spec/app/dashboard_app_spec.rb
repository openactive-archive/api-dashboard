require 'spec_helper'
require_relative '../../dashboard_app'

describe DashboardApp do

  def app
    DashboardApp
  end

  before(:all) do
    example = { "mywebsait/opendata" => 
      {
        "dataset-site-url"=>"http://data.activenewham.org.uk/",
        "title"=>"activeNewham Sessions",
        "description"=>"Session data from the activenewham.org.uk site",
        "publisher-name"=>"activeNewham",
        "publisher-url"=>"https://www.activenewham.org.uk",
        "data-url"=>"https://activenewham-openactive.herokuapp.com",
        "documentation-url"=>"https://github.com/activenewham/opendata",
        "license-name"=>"Creative Commons Attribution Licence (CC-BY v4.0)",
        "license-url"=>"https://creativecommons.org/licenses/by/4.0/",
      }
    }
    Redis.current.set('datasets', example.to_json)
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

end