require 'request_info/config'
require 'request_info/results'
require 'request_info/version'

# Optionally use railtie if Rails is available
require 'request_info/railtie' if defined?(Rails)

module RequestInfo
  autoload :GeoIp, 'request_info/geoip'
  autoload :Locale,  'request_info/locale'
  autoload :CountryLocaleMap, 'request_info/country_locale_map'
  autoload :LocaleNameMap, 'request_info/locale_name_map'
  autoload :Timezone, 'request_info/timezone'
  autoload :DetectorApp, 'request_info/detector_app'
  autoload :Detectors, 'request_info/detectors'
  autoload :Detector, 'request_info/detector'
  autoload :IpDetector, 'request_info/ip_detector'
  autoload :LocaleDetector, 'request_info/locale_detector'
  autoload :TimezoneDetector, 'request_info/timezone_detector'
  autoload :Timezone, 'request_info/timezone'
  #autoload :Tests,   'request_info/tests'

  class << self
binding.pry
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
