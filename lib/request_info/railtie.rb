require "request_info/detector_app"
require "request_info/geoip"
require "rails/railtie"

module RequestInfo
  class Railtie < ::Rails::Railtie
    # config.before_initialize do
    # end

    # Insert DetectorApp middleware
    initializer :setup_request_info, group: :all do |app|
      app.config.middleware.use RequestInfo::DetectorApp
    end

    # Preload databases after initialization since initializers may modify
    # geoipdb_path
    config.after_initialize do
      RequestInfo.preload
    end
  end
end
