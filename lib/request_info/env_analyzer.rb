module RequestInfo
  class EnvAnalyzer
    attr_reader :detectors

    def initialize(detectors)
      @detectors = detectors
    end

    def detect(*args)
      RequestInfo.results = RequestInfo::Results.new

      detectors.each do |d|
        d.instance.detect(*args)
      end
    end

    def before_app(*args)
      detectors.each do |d|
        d.instance.before_app(*args)
      end
    end

    def after_app(*args)
      detectors.each do |d|
        d.instance.after_app(*args)
      end
    end
  end
end
