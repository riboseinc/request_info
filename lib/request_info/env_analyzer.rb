module RequestInfo
  class EnvAnalyzer
    def initialize(detectors)
      detectors.each { |d| extend(d) }
    end

    def detect(*args)
      RequestInfo.results = RequestInfo::Results.new
    end

    def before_app(*args)
    end

    def after_app(*args)
    end
  end
end
