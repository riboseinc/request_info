require "request_info/version"

require "request_info/config"
require "request_info/detector_app"
require "request_info/results"

# Optionally use railtie if Rails is available
require "request_info/railtie" if defined?(Rails)

module RequestInfo

  class << self
    # Get current configuration
    def config
      Thread.current[:request_info_config] ||=
        RequestInfo::Config.new
    end

    # Set configuration
    def config=(value)
      Thread.current[:request_info_config] = value
    end

    # Get detection results
    def results
      Thread.current[:request_info_results] ||=
        RequestInfo::Results.new
    end

    # Set results
    def results=(value)
      Thread.current[:request_info_results] = value
    end
  end
end
