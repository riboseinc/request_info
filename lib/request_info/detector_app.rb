# (c) Copyright 2017 Ribose Inc.
#

require "request_info/detectors/browser_detector"
require "request_info/detectors/ip_detector"
require "request_info/detectors/timezone_detector"
require "request_info/detectors/locale_detector"

module RequestInfo
  # Rack middleware to process all specified detectors and sets results for the
  # current thread
  class DetectorApp
    class << self
      attr_accessor :detectors
    end

    attr_reader :analyzer, :app

    def initialize(app)
      @app = app

      # TODO: make this list of detectors available for others to add/change
      if !self.class.detectors
        self.class.detectors = [
          RequestInfo::Detectors::IpDetector,
          RequestInfo::Detectors::BrowserDetector,
          RequestInfo::Detectors::TimezoneDetector,
          RequestInfo::Detectors::LocaleDetector,
        ]
      end

      @analyzer = EnvAnalyzer.new(self.class.detectors)
    end

    def call(env)
      analyzer.analyze(env)
      analyzer.wrap_app do
        app.call(env)
      end
    end
  end
end
