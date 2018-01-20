require "request_info/geoip"
require "rails/railtie"

module RequestInfo
  class Railtie < ::Rails::Railtie

    # config.before_initialize do
    # end

    # Insert DetectorApp middleware
    initializer :setup_request_info, :group => :all do |app|
      app.config.middleware.use RequestInfo::DetectorApp
    end

    # Setup GeoIP database after initialization since initializers may modify
    # geoip_path
    config.after_initialize do
      GeoIP.setup
    end

  end
end

