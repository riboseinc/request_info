module RequestInfo
  class EnvAnalyzer
    def initialize(detectors)
      detectors.each { |d| extend(d) }
    end

    def analyze(_env)
      RequestInfo.results = RequestInfo::Results.new
    end

    def wrap_app
      yield
    end
  end
end
