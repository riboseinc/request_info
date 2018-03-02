require "request_info/locale"
require "i18n"

module RequestInfo
  module Detectors
    module LocaleDetector
      def detect(env)
        super

        results = RequestInfo.results

        # Find compatible locales
        compat = RequestInfo::Locale.compatible_langs(
          accept_language(env),
        )

        # puts "Compatible locales! #{compat.inspect}"

        # Set our locale in multiple places, including in env, I18n.locale, and
        # in this rack middleware.
        #
        # The locale can be accessed in Rails in these ways:
        #   I18n.locale
        #   request.env['request_info.locale.detected']
        #
        # Note: compat is a 2-d array with quality factors so we take the first
        # of the first.
        #
        # Note 2: we clear off this modification in after_app

        # If we are not compatible with any detected locales, use
        # default locale.
        locale = compat.empty? ? ::I18n.default_locale.to_s : compat.first.first

        results.locale = locale
        results
      end

      def wrap_app
        detected_locale = RequestInfo.results.locale
        @@old_locale = ::I18n.locale
        ::I18n.locale = detected_locale

        status, headers, body = super

        # Set header language back to the client
        headers["Content-Language"] = RequestInfo.results.locale

        # Reset our modifications after app is finished
        ::I18n.locale = @@old_locale

        [status, headers, body]
      end

      private

      # Extracts Accept-Language from env
      #
      def accept_language(env)
        env["HTTP_ACCEPT_LANGUAGE"]
      end
    end
  end
end
