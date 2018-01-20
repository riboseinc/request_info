require "request_info/detector"
require "request_info/locale"
require "i18n"

class RequestInfo::LocaleDetector < RequestInfo::Detector
  def detect(env)
    @@old_locale = ::I18n.locale

    # Find compatible locales
    compat = RequestInfo::Locale.compatible_langs(
      accept_language(env)
    )

    # puts "Compatible locales! #{compat.inspect}"

    # Set our locale in multiple places, including in env, I18n.locale, and in
    # this rack middleware.
    #
    # The locale can be accessed in Rails in these ways:
    #   I18n.locale
    #   request.env['request_info.locale.detected']
    #
    # Note: compat is a 2-d array with quality factors so we take the first of
    # the first.
    #
    # Note 2: we clear off this modification in after_app
    locale = unless compat.empty?
               env["request_info.locale.detected"] =
                 ::I18n.locale =
                   compat.first.first
             else
               # If we are not compatible with any detected locales, use default locale.
               ::I18n.default_locale.to_s
    end

    {
      locale: locale
    }
  end

  def after_app(status, headers, body)
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
