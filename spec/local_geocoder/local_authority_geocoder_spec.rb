require 'spec_helper'

describe LocalGeocoder::LocalAuthorityGeocoder do

  let(:geocoder) { LocalGeocoder::LocalAuthorityGeocoder.new() }

  describe "#reverse_geocode" do
    it "should return the correct local authority" do
      result = geocoder.reverse_geocode(-0.08660358, 51.27262669)
      expect(result.short_name).to eql "Tandridge"
    end

    it "should return nil when unable to reverse geocode an authority" do
      result = geocoder.reverse_geocode(0.0, 0.0)
      expect(result).to eql nil
    end
  end

end