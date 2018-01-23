module RequestInfo
  class Configuration
    # Path to the locale-name map csv file
    def locale_name_map_path
      @@locale_name_map_path ||= File.expand_path(
        "../../../data/locale_name_map.csv",
        __FILE__,
      )
    end

    def locale_name_map_path=(path)
      @@locale_name_map_path = path.to_s
    end

    # Path to the country-locale map csv file
    def locale_map_path
      @@locale_map_path ||= File.expand_path(
        "../../../data/country_locale_map.csv",
        __FILE__,
      )
    end

    def locale_map_path=(path)
      @@locale_map_path = path.to_s
    end

    # Path to the GeoIPCity .dat file
    def geoip_path
      @@geoip_path ||=
        ENV["GEOIPDBPATH"] ||
        "/usr/local/GeoIP/GeoIP2-City.mmdb"
    end

    def geoip_path=(path)
      @@geoip_path = path.to_s
    end
  end
end
