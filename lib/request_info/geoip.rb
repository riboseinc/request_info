# (c) Copyright 2017 Ribose Inc.
#

require "maxmind_geoip2"
require "singleton"

# Our interface to GeoIP.
#
# Provides 2 module functions:
#   setup
#   lookup(ip)
#
module RequestInfo
  class GeoIP
    include Singleton

    attr_accessor :database

    # Sets up the GeoIPCity database for upcoming queries
    def initialize
      print "[request_info] setting up geoip database... "

      self.database = MaxmindGeoIP2

      MaxmindGeoIP2.file(
        RequestInfo.configuration.geoipdb_path,
      )
      MaxmindGeoIP2.locale("en")

      puts "Done."
    rescue LoadError
      Rails.logger.warn "[request_info] Warning: " +
        "Gem maxmind_geoip2 not found (>=0.0.8)"
    rescue
      Rails.logger.warn (
        "[request_info] Warning: Unable to initialize GeoIP database: " +
        "'#{RequestInfo.config.geoipdb_path}'. " +
        "Check configuration."
      )
    end

    ## FOR TESTING
    ## geoinfo = GeoIp.lookup('116.49.226.82')
    ## geoinfo = GeoIp.lookup('24.24.24.24')

    # Looks up the specified IP address (string) and returns information about
    # the IP address.
    #
    # Information currently comes from GeoIPCity.
    #
    def lookup(ip)
      # Quit if database or IP not present
      return nil unless self.database && ip && !ip.blank?

      # Rails.logger.warn "[request_info] locate results #{self.database.locate(ip).inspect}"
      self.database.locate(ip)
    end
  end
end
