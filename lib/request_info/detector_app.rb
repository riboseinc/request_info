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
    detect_results(env)
    prepare_for_app_call(env)
    status, headers, body = @app.call(env)
    clean_detection(status, headers, body)
    [status, headers, body]
  end

  private

  # Runs all specified detectors in the same order on a request, and sets the
  # results to RequestInfo.results
  #
  def detect_results(env)
    analyzer.detect(env)
  end

  def prepare_for_app_call(env)
    analyzer.before_app(env)
  end

  # Runs each detector's "after_app" method after the app has run.
  #
  # A Detector may use this to reset any transient states changed by itself
  # during detection.
  #
  # Another usage is to set headers or status used to respond to the client.
  #
  def clean_detection(*args)
    analyzer.after_app(*args)
  end
end
