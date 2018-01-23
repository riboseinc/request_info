require "request_info/version"

require "request_info/configuration"
require "request_info/detector_app"
require "request_info/results"

# Optionally use railtie if Rails is available
require "request_info/railtie" if defined?(Rails)

module RequestInfo

  class << self
    # Get detection results
    def results
      Thread.current[:request_info_results] ||=
        RequestInfo::Results.new
    end

    # Set results
    def results=(value)
      Thread.current[:request_info_results] = value
    end

    def configure
      @mutable_configuration ||= Configuration.new
      yield @mutable_configuration if block_given?
      @configuration = @mutable_configuration.dup.tap(&:freeze)
    end

    def configuration
      configure if @configuration.nil?
      @configuration
    end
  end
end
