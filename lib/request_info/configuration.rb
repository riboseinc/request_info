# (c) Copyright 2017 Ribose Inc.
#

module RequestInfo
  class Configuration
    attr_accessor :locale_name_map_path, :locale_map_path, :geoip2_db_path

    def initialize
      set_defaults
    end

    private

    def set_defaults
      self.locale_name_map_path = default_locale_name_map_path
      self.locale_map_path = default_locale_map_path
      self.geoip2_db_path = nil
    end

    def default_locale_name_map_path
      File.expand_path("data/locale_name_map.csv", gem_root)
    end

    def default_locale_map_path
      File.expand_path("data/country_locale_map.csv", gem_root)
    end

    def gem_root
      File.expand_path("../../..", __FILE__)
    end
  end
end
