require "request_info/detectors/base"
require "request_info/locale"
require "i18n"

module RequestInfo
  module Detectors
    class LocaleDetector < Base
      def detect(env)
        @@old_locale = ::I18n.locale

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

        ::I18n.locale = locale

        {
          locale: locale,
        }
      end

      def after_app(_status, headers, _body)
        # Set header language back to the client
        headers["Content-Language"] = RequestInfo.results.locale

        # Reset our modifications after app is finished
        ::I18n.locale = @@old_locale
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
