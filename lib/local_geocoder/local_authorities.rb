require 'local_geocoder'
module LocalGeocoder

  class LocalAuthorities

    attr_reader :data

    def initialize(features_path=ENV["LA_GEOJSON_PATH"])
      @data = load_data(features_path)
    end

    private

    def load_data(features_path)
      features = JSON.load(File.open(features_path))['features']
      features.map do |f|
        id = f['properties']['lad16nm']

        # Note: Perimeter is always first element in GeoJSON.
        geometries = case f['geometry']['type']
        when "MultiPolygon"
          f['geometry']['coordinates'].map { |g| LocalGeocoder::Geometry::Polygon.from_point_array(g.first) }
        when "Polygon"
          Array(LocalGeocoder::Geometry::Polygon.from_point_array(f['geometry']['coordinates'].first))
        else
          raise "Don't know how to handle geometry type: #{f['geometry']['type']}"
        end
        LocalGeocoder::Entity.new(id, f['properties']['name'], geometries)
      end
    end

  end

end