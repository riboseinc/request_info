# (c) Copyright 2017 Ribose Inc.
#

module RequestInfo
  class Configuration
    attr_accessor :geoip2_db_path

    def initialize
      set_defaults
    end

    private

    def set_defaults
      self.geoip2_db_path = nil
    end
  end
end
