module LocalGeocoder

  LAEntity = Struct.new(:id, :name, :geometries) do
    def inspect
      "#{self.id} #{self.name}"
    end
  end

  class LocalAuthorities

    attr_reader :data, :dictionary

    def initialize(features_path=ENV["LA_GEOJSON_PATH"])
      @data, @dictionary = load_data(features_path)
    end

    private

    def load_data(features_path)
      features = JSON.load(File.open(features_path))['features']
      dictionary = {}
      data = features.map do |f|
        la_name = f['properties']['lad16nm']
        la_id = f['properties']['lad16cd']

        # Note: Perimeter is always first element in GeoJSON.
        geometries = case f['geometry']['type']
        when "MultiPolygon"
          f['geometry']['coordinates'].map { |g| LocalGeocoder::Geometry::Polygon.from_point_array(g.first) }
        when "Polygon"
          Array(LocalGeocoder::Geometry::Polygon.from_point_array(f['geometry']['coordinates'].first))
        else
          raise "Don't know how to handle geometry type: #{f['geometry']['type']}"
        end

        dictionary[la_name] = la_id
        LocalGeocoder::LAEntity.new(la_id, la_name, geometries)
      end
      return [data, dictionary]
    end

  end

end