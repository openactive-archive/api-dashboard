require 'spec_helper'

describe DashboardMetrics do

  before(:each) do
    WebMock.stub_request(:get, "https://openactive-staging-metrics.herokuapp.com/metrics").
      to_return(:status => 200, :body => "", :headers => {})
  end

  describe ".all" do
    it "connects and lists available metrics" do
      DashboardMetrics.all
    end
  end

end