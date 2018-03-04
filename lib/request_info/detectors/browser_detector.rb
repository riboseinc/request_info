# (c) Copyright 2017 Ribose Inc.
#

require "browser/browser"

module RequestInfo
  module Detectors
    module BrowserDetector
      def analyze(env)
        super
        RequestInfo.results.browser = detect_browser(env)
      end

      private

      def detect_browser(env)
        ua = env["HTTP_USER_AGENT"]
        lang = env["HTTP_ACCEPT_LANGUAGE"]
        Browser.new(ua, accept_language: lang)
      end
    end
  end
end
