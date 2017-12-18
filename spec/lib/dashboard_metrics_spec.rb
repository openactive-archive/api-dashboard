require 'spec_helper'

describe DashboardMetrics do

  before(:each) do
    WebMock.stub_request(:get, "https://openactive-staging-metrics.herokuapp.com/metrics").
      to_return(:status => 200, :body => "")
    WebMock.stub_request(:post, "https://openactive-staging-metrics.herokuapp.com/metrics/dataset-count").
      to_return(:status => 201, :body => "")
  end

  describe ".all" do
    it "connects and lists available metrics" do
      DashboardMetrics.all
    end
  end

  describe ".dataset_count" do
    it "returns a count of all datasets" do
      expect(DashboardMetrics.dataset_count).to eql(DatasetsCache.all.keys.size)
    end
  end

  describe ".report_dataset_count" do
    it "sends to bothan count of all datasets" do
      r = DashboardMetrics.report_dataset_count
      expect(r.response.code).to eql("201")
    end
  end

end