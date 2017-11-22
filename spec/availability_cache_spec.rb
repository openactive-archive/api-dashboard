require 'spec_helper'

describe AvailabilityCache do

  before(:all) do
    Redis.current.set('datasets', load_fixture("single-dataset.json"))
  end

  before(:each) do
    Redis.current.del('availability')
  end

  describe ".update" do
    it "stores availability if there were no issues making requests" do    
      WebMock.stub_request(:get, "https://activenewham-openactive.herokuapp.com").to_return(:status => 200)

      result = AvailabilityCache.update
      not_updated = Redis.current.get('availability').nil?

      expect(result).to be(true).or be(false)

      if result
        expect(not_updated).to be(false)
        availability = JSON.parse(Redis.current.get('availability'))
        expect(availability.keys.size).to be > 0
        expect(availability.class).to eql(Hash)
      else
        puts "Availability cache was not updated"
        expect(not_updated).to be(true)
      end
    end

    it "correctly flags unavailable endpoints" do
      WebMock.stub_request(:get, "https://activenewham-openactive.herokuapp.com").to_return(:status => 500)
      AvailabilityCache.update
      availability = JSON.parse(Redis.current.get('availability'))
      expect(availability["https://activenewham-openactive.herokuapp.com"]).to be false
     end

     it "correctly flags available endpoints" do
      WebMock.stub_request(:get, "https://activenewham-openactive.herokuapp.com").to_return(:status => 200)
      AvailabilityCache.update
      availability = JSON.parse(Redis.current.get('availability'))
      expect(availability["https://activenewham-openactive.herokuapp.com"]).to be true
     end
  end

  describe ".all" do
    it "retrieves a collection of availabilities" do
      example = { "https://ourparks.org.uk/getSessions" => true }
      Redis.current.set('availability', example.to_json)
      availability = AvailabilityCache.all
      expect(availability.class).to eql(Hash)
      expect(availability.keys.size).to be > 0
      expect(availability["https://ourparks.org.uk/getSessions"]).to eql(true)
    end
  end

  describe ".fetch" do
    it "raises an error if there were too many redirects" do
      expect { AvailabilityCache.fetch("https://ourparks.org.uk/getSessions", 0) }.to raise_error(StandardError)
    end

    it "returns an HTTP response code" do
      WebMock.stub_request(:get, "https://ourparks.org.uk/getSessions")
      response_code = AvailabilityCache.fetch("https://ourparks.org.uk/getSessions")
      is_http_code = (100..527).include?(response_code.to_i)
      expect(is_http_code).to be true
    end
  end

end