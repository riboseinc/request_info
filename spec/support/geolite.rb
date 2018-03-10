# (c) Copyright 2017 Ribose Inc.
#

dbpath = File.expand_path("../../../geolitedb/GeoLite2-City.mmdb", __FILE__)
RequestInfo.configure { |config| config.geoip2_db_path = dbpath }
