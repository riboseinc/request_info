# (c) Copyright 2017 Ribose Inc.
#

require "request_info/country_locale_map"

# RequestInfo::Locale is used to detect the remote request's locale in
# the following order:
#   1. Browser http_accept_header
#   2. Remote IP address
#
# IP locale detection has lower priority than the accept header as it
# can be wrong on certain cases (e.g. user goes abroad with the same
# computer).
#
# The process first gathers all possible locales via the above criteria,
# and then tries to find compatible locales supported on the server. In
# the whole process a "quality factor" (a float) accompanies the locale
# id in order to maintain the user's preference of locale (from
# http_accept_header).
#
# http_accept_header's quality factor value ranges from 0.0 to 1.0 where
# 1.0 is highest. Therefore we provide a negative number to locales from
# IP detection when we sort compatible locales so the order is
# preserved.
#

module RequestInfo::Locale
  class << self
    # Languages determined by ip lookup. Each country and region may
    # have a different order of preference for languages.
    #
    # e.g ISO3166 "HK" prefers zh-HK, en-HK then zh
    # e.g ISO3166 "CH" prefers de-CH, fr-CH, it-CH then rm
    #
    # Returns the format of [langcode, q] as in browser_langs.
    #
    # Quality factor here is set to negative to prevent collision with
    # browser_langs, as IP locale detection has lower priority than
    # browser locale detection.
    #
    def ip_langs
      # Use results from IpDetector
      ipinfo = RequestInfo.results.ipinfo
      return [] unless ipinfo

      # Get languages for country from country-locale map
      langs = RequestInfo::CountryLocaleMap.instance.country_code_locales(
        ipinfo["country_code"],
      )

      # Return downcased locale id with -ve quality factor.
      #
      # Value decreases in steps of 0.01 to maintain the preference in
      # CountryLocaleMap
      q = 0
      langs.map do |l|
        q -= 0.01
        [l, q]
      end
    end

    # Returns the remote IP of the request env
    # Finds compatible locales between the user and server.
    #
    # Uses both browser locale detection and remote IP locale detection.
    #
    # Returns an array of compatible locales in this format:
    #   [ [ localeid, qualityfactor ], ...]
    #   where qualityfactor is a float.
    #
    def compatible_langs(accept_lanugage)
      # Priority in this order:
      #  - browser locale
      #  - ip locale

      langs = sort_by_quality(
        browser_langs(accept_lanugage) +
        ip_langs,
      )

      # I18n.available_languages are downcased
      avail = I18n.available_locales.map(&:to_s)

      unmatched = langs.dup

      # First obtain direct matches, where both language + region match
      #
      # We increase the quality factor of matches here by 10 in order to
      # differentiate them with IP detected locales.
      compat = langs.inject([]) do |acc, (l, q)|
        matched = avail.detect do |k| # en
          l == k
        end
        if matched
          unmatched.reject! { |j| j.first == l }
          acc << [matched, q + 10]
        else
          acc
        end
      end

      # Now we match only the language code without the region. As it is
      # not an exact match we keep the quality factor between 0.0 and 1.0.
      #
      # E.g  "en-UK" is considered to match "en-US" and "en-FR".
      #
      compat += unmatched.inject([]) do |acc, (l, q)|
        matched = avail.detect do |k| # en
          l.split("-", 2).first == k.split("-", 2).first
        end
        matched ?
          acc << [matched, q] :
          acc
      end

      # TODO: remove duplicated locales, only keep the highest score for each
      # duplicated locale

      # sort langs by quality factor
      sort_by_quality(compat)
    end

    # Returns a sorted array of locale-id and quality pairs, given one of
    # the same type.
    #
    # Input/Output: [ [localeid, qualityfactor], ... ]
    #
    def sort_by_quality(arr)
      arr.sort do |(_a, b), (_x, y)|
        y <=> b
      end
    end

    # Returns the languages requested by browser as:
    #
    #   [localeid, q]
    #     where,
    #     localeid: the downcased locale code
    #     q: quality factor from 0.0-1.0 where a higher value indicates
    #     higher preference
    #
    # Refer to http://www.ietf.org/rfc/rfc2616.txt Section 14.4
    #
    def browser_langs(accept)
      return [] unless accept

      # obtain languages and split quality factor
      langs = accept.
        split(/\s*,\s*/).
        inject([]) do |acc, l|

        # without q means 1.0
        unless l =~ /;q=\d+\.\d+$/
          l += ";q=1.0"
        end
        lang, q = l.split(";q=")

        # reject bad language codes
        unless lang =~ /^[a-z\-]+$/i
          acc
        else
          # downcase language codes
          lang = lang.downcase

          # parse quality factor as float
          q = q.to_f

          acc << [lang, q]
        end
      end.compact

      # sort langs by quality factor
      sort_by_quality(langs)
    rescue
      # Return empty array if something bad happened
      []
    end
  end
end
