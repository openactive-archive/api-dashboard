require 'local_geocoder'
require_relative 'local_authorities'

module LocalGeocoder

  class LocalAuthorityGeocoder

    attr_reader :features_path

    def initialize(features_path=ENV["LA_GEOJSON_PATH"])
      @features_path = features_path
    end

    def local_authorities
      @local_authorities ||= LocalAuthorities.new(features_path)
    end

    def reverse_geocode(lng, lat)
      find_result(lng, lat)
    end

    private

    def find_result(lng, lat)
      local_authorities.data.find { |la| contains_location?(la, lng, lat) }
    end

    def contains_location?(entity, lng, lat)
      entity.geometries.any? { |g| g.contains_point?(Geometry::Point.new(lng, lat)) }
    end

  end

end