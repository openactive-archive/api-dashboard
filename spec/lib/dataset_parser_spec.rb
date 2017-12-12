require 'spec_helper'

describe DatasetParser do

  let(:parser) { Class.new { extend DatasetParser } }

  describe "#parse_modified" do
    it "parses various date formats" do
      expect(parser.parse_modified("1496565686")).to eql(1496565686)
      expect(parser.parse_modified(1512457484704)).to eql(1512457484)
      expect(parser.parse_modified("2017-09-22T12:35:02.511Z")).to eql(1506083702)
    end
  end

  describe "#extract_activities" do

    it "extracts activity name in a string" do
      item = { "data" =>{ "activity"=>"Body Attack" } }
      expect(parser.extract_activities(item)).to eql(["Body Attack"])
    end

    it "extracts activity name in a hash" do
      item = { "data" =>{ "activity"=>{ "prefLabel" => "Body Attack" } } }
      expect(parser.extract_activities(item)).to eql(["Body Attack"])
    end

    it "extracts activity names in an array of strings" do
      item = { "data" =>{ "activity"=>["Body Attack", "Boxing Fitness"] } }
      expect(parser.extract_activities(item)).to eql(["Body Attack", "Boxing Fitness"])
    end

    it "extracts activity names in an array of hashes" do
      item = { "data" =>{ "activity"=>[{ "prefLabel" => "Body Attack" },
        { "prefLabel" => "Boxing Fitness" } ]}
      }
      expect(parser.extract_activities(item)).to eql(["Body Attack", "Boxing Fitness"])
    end

    it "returns empty if there's no activity key" do
      item = { "data" =>{ "activity_names"=>["Body Attack", "Boxing Fitness"]} }
      expect(parser.extract_activities(item)).to eql([])
    end

  end

  describe "#extract_coordinates" do
    it "extracts latitude and longitude" do
      item = {
        "data" =>{ "location"=> { "geo" => { "latitude" => "51.0", "longitude" => "0.23" } } }
      }

      item2 = {
        "data" =>{ "location"=> { "containedInPlace" => {
          "geo" => { "latitude" => "52.0", "longitude" => "0.24" } } }
        }
      }

      expect(parser.extract_coordinates(item)).to eql([0.23, 51.0])
      expect(parser.extract_coordinates(item2)).to eql([0.24, 52.0])
    end

    it "returns false when no location available" do
      item = {
        "data" =>{ "location" => { "address" => "a street" } }
      }
      item2 = {
        "data" =>{ "other" => "stuff" }
      }
      expect(parser.extract_coordinates(item)).to eql(false)
      expect(parser.extract_coordinates(item2)).to eql(false)
    end

    it "returns false when coordinates are null" do
      item = {
        "data" =>{ "location"=> { "geo" => { "latitude" => nil, "longitude" => nil } } }
      }
      item2 = {
        "data" =>{ "location"=> { "geo" => nil } }
      }
      expect(parser.extract_coordinates(item)).to eql(false)
      expect(parser.extract_coordinates(item2)).to eql(false)
    end

    it "returns false when coordinates are all 0" do
      item = {
        "data" =>{ "location"=> { "geo" => { "latitude" => "0.0000", "longitude" => "0.0000" } } }
      }
      expect(parser.extract_coordinates(item)).to eql(false)
    end
  end

  describe "#extract_timestamp" do
    it "returns date timestamp for various formats" do

      item1 = {
        "data" =>{ "startDate"=> "2017-09-22T12:35:02.511Z" }
      }

      item2 = {
        "data" =>{ "subEvent" => { "startDate"=> "2017-09-22T12:35:02.511Z" } }
      }

      item3 = {
        "data" =>{ "subEvent" => [{ "startDate"=> "2017-09-22T12:35:02.511Z" }] }
      }

      item4 = {
        "data" =>{ "eventSchedule" => { "startDate"=> "2017-09-22T12:35:02.511Z" } }
      }

      expect(parser.extract_timestamp(item1, "startDate")).to eql(1506083702)
      expect(parser.extract_timestamp(item2, "startDate")).to eql(1506083702)
      expect(parser.extract_timestamp(item3, "startDate")).to eql(1506083702)
      expect(parser.extract_timestamp(item4, "startDate")).to eql(1506083702)
    end
  end

end