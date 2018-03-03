# (c) Copyright 2017 Ribose Inc.
#

require "i18n"
require "request_info/country_locale_map"

module RequestInfo
  module Detectors
    module LocaleDetector
      def analyze(env)
        super
        RequestInfo.results.locale = detect_locale
      end

      def wrap_app
        detected_locale = RequestInfo.results.locale
        previous_locale = ::I18n.locale
        ::I18n.locale = detected_locale

        status, headers, body = super

        # Set header language back to the client
        headers["Content-Language"] = RequestInfo.results.locale

        # Reset our modifications after app is finished
        ::I18n.locale = previous_locale

        [status, headers, body]
      end

      private

      def detect_locale
        available_locales = ::I18n.available_locales.map(&:to_s)
        user_preference.detect { |l| available_locales.include?(l) }
      end

      # Returns enumerator which yields locales which are preferred by user,
      # starting with the best matching one.  The user preference is defined as
      # concatenation of locales in Accept-Language HTTP header (already sorted
      # according to respective weights), locales matching the user's location
      # (guessed from the IP address), and finally the application's default
      # locale.
      #
      # It is not guaranteed that these locales are available in I18n.
      def user_preference
        Enumerator.new do |y|
          browser_locales.each { |l| y << l }
          ip_locales.each { |l| y << l }
          y << default_locale
        end
      end

      # Locales preferred by user according to Accept-Language HTTP header.
      def browser_locales
        locales_arr = RequestInfo.results.browser.try(:accept_language) || []
        locales_arr.flat_map { |l| [l.full, l.code] }
      end

      # Guessing of locales preferred by user basing on his location.
      def ip_locales
        ipinfo = RequestInfo.results.ipinfo || {}
        country_code = ipinfo["country_code"]
        return [] unless country_code
        locales = CountryLocaleMap.instance.country_code_locales(country_code)
        locales + locales.map { |l| l.split(/\W/, 2).first }
      end

      def default_locale
        ::I18n.default_locale.to_s
      end
    end
  end
end
