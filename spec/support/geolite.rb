# (c) Copyright 2017 Ribose Inc.
#

unless ENV.fetch("DISABLE_GEOIP2", false)
  dbpath = File.expand_path("../../../geolitedb/GeoLite2-City.mmdb", __FILE__)
  RequestInfo.configure { |config| config.geoip2_db_path = dbpath }
end
