require 'spec_helper'
require_relative '../../dashboard_helpers'

describe DashboardHelpers do

  let(:dummy_class) do
    class DummyClass
      include DashboardHelpers
    end
    DummyClass.new
  end

  describe ".licence_image" do

    it "builds an image tag with appropriate cc image as source" do
      expect(dummy_class.licence_image("https://creativecommons.org/licenses/by/4.0/")).to eql('<img class="licence-image" src="/images/by.png">')
      expect(dummy_class.licence_image("https://creativecommons.org/licenses/by-nc/4.0/")).to eql('<img class="licence-image" src="/images/by-nc.png">')
      expect(dummy_class.licence_image("https://creativecommons.org/licenses/by-nd/4.0/")).to eql('<img class="licence-image" src="/images/by-nd.png">')
    end

    it "builds an image tag with default image as source if not a cc licence" do
      expect(dummy_class.licence_image("https://myothersite.org/licenses/mylicence/")).to eql('<img class="licence-image" src="/images/licence.png">')
    end

  end

  describe ".availability_indicator" do

    it "renders the correct indicator based on the result of the availability value" do
      availability = { 
        "https://myfirstsite.org/data-endpoint" => true, 
        "https://myothersite.org/data-endpoint" => false
      }
      expect(dummy_class.availability_indicator(availability, availability.keys[0])).to eql('<span class="green-light"></span>Up')
      expect(dummy_class.availability_indicator(availability, availability.keys[1])).to eql('<span class="red-light"></span>Down')
      expect(dummy_class.availability_indicator(availability, "http://unknown.site/endpoint")).to eql('<span title="Unknown" class="gray-light"></span> Unknown')
    end

  end

  describe ".yesno_indicator" do

    it "renders the correct indicator" do
      expect(dummy_class.yesno_indicator(true)).to eql('<span class="green-light"></span>Yes')
      expect(dummy_class.yesno_indicator(false)).to eql('<span class="red-light"></span>No')
      expect(dummy_class.yesno_indicator(nil)).to eql('<span title="Unknown" class="gray-light"></span>')
    end

  end

end