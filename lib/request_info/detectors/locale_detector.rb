# (c) Copyright 2017 Ribose Inc.
#

require "request_info/locale"
require "i18n"

module RequestInfo
  module Detectors
    module LocaleDetector
      def analyze(env)
        super

        results = RequestInfo.results

        # Find compatible locales
        compat = RequestInfo::Locale.compatible_langs(
          accept_language(env),
        )

        locale = compat.empty? ? default_locale : compat.first.first
        results.locale = locale
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

      # Extracts Accept-Language from env
      #
      def accept_language(env)
        env["HTTP_ACCEPT_LANGUAGE"]
      end

      def default_locale
        ::I18n.default_locale.to_s
      end
    end
  end
end
