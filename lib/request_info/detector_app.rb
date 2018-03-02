require "request_info/detectors/ip_detector"
require "request_info/detectors/timezone_detector"
require "request_info/detectors/locale_detector"

# Rack middleware to process all specified detectors and sets results for the
# current thread
class RequestInfo::DetectorApp
  class << self
    attr_accessor :detectors
  end

  attr_reader :analyzer

  def initialize(app)
    @app = app

    # TODO: make this list of detectors available for others to add/change
    if !self.class.detectors
      self.class.detectors = [
        RequestInfo::Detectors::IpDetector,
        RequestInfo::Detectors::TimezoneDetector,
        RequestInfo::Detectors::LocaleDetector,
      ]
    end

    @analyzer = ::RequestInfo::EnvAnalyzer.new(self.class.detectors)
  end

  def call(env)
    analyzer.detect(env)
    analyzer.before_app(env)
    status, headers, body = @app.call(env)
    analyzer.after_app(status, headers, body)
    [status, headers, body]
  end
end
