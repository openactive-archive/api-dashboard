require 'spec_helper'

describe DatasetSummary do

  let(:summary) {
    DatasetSummary.new("example/opendata", "http://www.example.com")
  }

  before(:each) do
    Redis.current.zremrangebyrank("example/opendata", 0, -1)
    #Redis.current.zrange('example/opendata', 0, -1)
  end

  before(:each) do
    WebMock.stub_request(:get, "http://www.example.com").to_return(body: load_fixture("multiple-items.json"))
    WebMock.stub_request(:get, "http://www.example.com/last").to_return(body: load_fixture("last-page.json"))
  end

  describe "#is_page_recent?" do
    it "returns true if content is relevant within a year" do
      allow(Time).to receive_message_chain(:now, :to_i).and_return(1506335263)
      page = summary.feed.fetch
      expect(summary.is_page_recent?(page)).to eql(true)
    end

    it "returns false if content is not relevant within a year" do
      allow(Time).to receive_message_chain(:now, :to_i).and_return(1577836800)
      page = summary.feed.fetch
      expect(summary.is_page_recent?(page)).to eql(false)
    end

    it "should not include deleted items as relevant" do
      WebMock.stub_request(:get, "http://www.example.com").to_return(body: load_fixture("deleted-items.json"))
      allow(Time).to receive_message_chain(:now, :to_i).and_return(1506335263)
      page = summary.feed.fetch
      expect(summary.is_page_recent?(page)).to eql(false)
    end
  end

  describe "#harvest_activities" do
    it "increments score for harvested activities" do
      summary.harvest_activities
      score = Redis.current.zscore("example/opendata", "Body Attack")
      expect(score).to eql(1.0)
    end

    it "doesn't increment score once max samples reached" do
      summary.harvest_activities(0)
      score = Redis.current.zscore("example/opendata", "Body Attack")
      expect(score).to eql(nil)
    end
  end

  describe "#zincr_activities" do
    it "increments sorted set scores for extracted activity names" do
      item = { "data" => { "activity" => ["Body Attack", "Boxing Fitness"] } }
      summary.zincr_activities(item)
      score1 = Redis.current.zscore("example/opendata", "Body Attack")
      score2 = Redis.current.zscore("example/opendata", "Boxing Fitness")
      expect(score1).to eql(1.0)
      expect(score2).to eql(1.0)
    end
  end

  describe "#extract_activities" do

    it "extracts activity name in a string" do
      item = { "data" =>{ "activity"=>"Body Attack" } }
      expect(summary.extract_activities(item)).to eql(["Body Attack"])
    end

    it "extracts activity name in a hash" do
      item = { "data" =>{ "activity"=>{ "prefLabel" => "Body Attack" } } }
      expect(summary.extract_activities(item)).to eql(["Body Attack"])
    end

    it "extracts activity names in an array of strings" do
      item = { "data" =>{ "activity"=>["Body Attack", "Boxing Fitness"] } }
      expect(summary.extract_activities(item)).to eql(["Body Attack", "Boxing Fitness"])
    end

    it "extracts activity names in an array of hashes" do
      item = { "data" =>{ "activity"=>[{ "prefLabel" => "Body Attack" },
        { "prefLabel" => "Boxing Fitness" } ]} 
      }
      expect(summary.extract_activities(item)).to eql(["Body Attack", "Boxing Fitness"])
    end

    it "returns empty if there's no activity key" do
      item = { "data" =>{ "activity_names"=>["Body Attack", "Boxing Fitness"]} }
      expect(summary.extract_activities(item)).to eql([])
    end

  end

end