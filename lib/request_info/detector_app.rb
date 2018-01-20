require "request_info/detectors"
require "request_info/ip_detector"
require "request_info/timezone_detector"
require "request_info/locale_detector"

# Rack middleware to process all specified detectors and sets results for the
# current thread
class RequestInfo::DetectorApp
  class << self
    attr_accessor :detectors
  end

  def initialize(app)
    @app = app

    # TODO: make this list of detectors available for others to add/change
    if !self.class.detectors
      self.class.detectors = RequestInfo::Detectors.new
      [
        RequestInfo::IpDetector,
        RequestInfo::TimezoneDetector,
        RequestInfo::LocaleDetector,
      ].each do |d|
        self.class.detectors << d
      end
    end
  end

  def call(env)
    rescue_failed do
      detect_results(env)
    end

    status, headers, body = @app.call(env)

    rescue_failed do
      clean_detection(status, headers, body)
    end

    [status, headers, body]
  end

  # If our code goes awry still let Rails do its thing.
  def rescue_failed
    yield if block_given?
  rescue
    Rails.logger.error "[request_info] died in DetectorApp due to:"
    Rails.logger.error $!.inspect
    Rails.logger.error $!.backtrace.pretty_inspect
  end

  private

  # Runs all specified detectors in the same order on a request, and sets the
  # results to RequestInfo.results
  #
  def detect_results(env)
    RequestInfo.results = RequestInfo::Results.new

    self.class.detectors.each do |d|
      res = d.instance.detect(env)

      res.each_pair do |k, v|
        RequestInfo.results.send(
          "#{k}=",
          v,
        )
      end unless res.nil?
    end
  end

  # Runs each detector's "after_app" method after the app has run.
  #
  # A Detector may use this to reset any transient states changed by itself
  # during detection.
  #
  # Another usage is to set headers or status used to respond to the client.
  #
  def clean_detection(*args)
    self.class.detectors.each do |d|
      d.instance.after_app(*args)
    end
  end
end
