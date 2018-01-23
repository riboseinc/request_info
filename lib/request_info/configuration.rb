module RequestInfo
  class Configuration
    attr_accessor :locale_name_map_path, :locale_map_path, :geoip_path

    def initialize
      set_defaults
    end

    private

    def set_defaults
      self.locale_name_map_path = File.expand_path(
        "../../../data/locale_name_map.csv",
        __FILE__,
      )

      self.locale_map_path = File.expand_path(
        "../../../data/country_locale_map.csv",
        __FILE__,
      )

      self.geoip_path =
        ENV["GEOIPDBPATH"] ||
        "/usr/local/GeoIP/GeoIP2-City.mmdb"
    end
  end
end
