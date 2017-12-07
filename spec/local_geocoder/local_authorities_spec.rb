require 'spec_helper'

describe LocalGeocoder::LocalAuthorities do

  before(:each) do
  end

  describe ".new" do
    it "should parse geojson and init structs with geometries" do
      result = LocalGeocoder::LocalAuthorities.new()
      expect(result.local_authorities.size).to be > 0
      la = result.local_authorities.sample
      expect(la.class).to eql(LocalGeocoder::Entity)
      expect(la.short_name.empty?).to eql(false)
      expect(la.geometries.size).to be > 0
      geo_types = [LocalGeocoder::Geometry::Polygon, LocalGeocoder::Geometry::Rect, LocalGeocoder::Geometry::Point]
      expect(geo_types).to include(la.geometries.sample.class)
    end
  end

end