# (c) Copyright 2017 Ribose Inc.
#

require "maxmind_geoip2"
require "singleton"

module RequestInfo
  # Brigdes MaxmindGeoIP2.
  #
  # Examples:
  # RequestInfo::GeoIP.instance.lookup('116.49.226.82')
  # RequestInfo::GeoIP.instance.lookup('24.24.24.24')

  class GeoIP
    include Singleton

    attr_accessor :database

    # Sets up the GeoIPCity database for upcoming queries
    def initialize
      unless geoip2_db_path.nil?
        ensure_maxmind_geoip2_availability
        self.database = setup_database
      end
    end

    def setup_database
      MaxmindGeoIP2.file(geoip2_db_path)
      MaxmindGeoIP2.locale("en")
      MaxmindGeoIP2
    end

    # Looks up the specified IP address (string) and returns information about
    # the IP address.
    def lookup(ip)
      return nil if self.database.nil? || ip.blank?
      self.database.locate(ip)
    end

    def geoip2_db_path
      RequestInfo.configuration.geoip2_db_path
    end

    def ensure_maxmind_geoip2_availability
      MaxmindGeoIP2
    rescue LoadError
      raise "RequestInfo requires maxmind_geoip2 gem for GeoIP2 database " +
        "lookup. Refer to README for configuration details."
    end
  end
end
