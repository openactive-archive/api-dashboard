require 'spec_helper'

describe DashboardMetrics do
  before(:all) do
    example = { 
      "mytraining/opendata" => { 
        "title" => "mytraining", 
        "data-url" => "http://mytraining.com/data" 
      },
      "example/opendata" => { 
        "title" => "my example dataset", "data-url" => "http://example.com/data",
        "uses-opportunity-model" => true, "uses-paging-spec" => true 
      }, 
      "otherexample/opendata" => { 
        "title" => "otherexample.com", "data-url" => "http://otherexample.com/data",
        "uses-opportunity-model" => false, "uses-paging-spec" => true 
      }
    }
    Redis.current.set('datasets', example.to_json)
  end

  before(:each) do
    WebMock.stub_request(:get, "https://openactive-staging-metrics.herokuapp.com/metrics").
      to_return(:status => 200, :body => "")
    WebMock.stub_request(:post, "https://openactive-staging-metrics.herokuapp.com/metrics/dataset-count").
      to_return(:status => 201, :body => "")
    WebMock.stub_request(:post, "https://openactive-staging-metrics.herokuapp.com/metrics/standard-datasets").
      to_return(:status => 201, :body => "")
    WebMock.stub_request(:post, "https://openactive-staging-metrics.herokuapp.com/metrics/local-authorities-sample").
      to_return(:status => 201, :body => "")
    Redis.current.zremrangebyrank("example/opendata/boundary", 0, -1)
    Redis.current.zremrangebyrank("otherexample/opendata/boundary", 0, -1)
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

  describe ".standard_datasets" do
    it "returns a count of all standard conforming datasets" do
      
      expect(DashboardMetrics.standard_datasets).to eql(1)
    end
  end

  describe ".report_standard_datasets" do
    it "sends to bothan count of all standard conforming datasets" do
      r = DashboardMetrics.report_standard_datasets
      expect(r.response.code).to eql("201")
    end
  end

  describe ".local_authorities_sample" do
    it "returns a list of all local authorities that contain any opportunity data" do
      Redis.current.zincrby("example/opendata/boundary", 1, "Colchester")
      Redis.current.zincrby("example/opendata/boundary", 4, "Glasgow City")
      Redis.current.zincrby("otherexample/opendata/boundary", 1, "Colchester")

      result = DashboardMetrics.local_authorities_sample
      expect(result).to eql(2)
    end
  end

  describe ".report_local_authorities_sample" do
    it "sends to bothan count of all standard conforming datasets" do
      r = DashboardMetrics.report_local_authorities_sample
      expect(r.response.code).to eql("201")
    end
  end

end