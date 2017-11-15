require 'spec_helper'
require_relative '../../dashboard_app'

describe DashboardApp do

  def app
    DashboardApp
  end

  it "includes google analytics code from environment variable" do
    ENV["GOOGLE_ANALYTICS_CODE"] = 'UA-XYZXYZ-Y'
    get "/"
    ga_code_setup = "ga('create', 'UA-XYZXYZ-Y', 'auto');"
    expect(last_response.status).to eq 200
    expect(last_response.body).to include(ga_code_setup)
  end

end