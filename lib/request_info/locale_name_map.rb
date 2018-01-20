require "csv"
require "singleton"

#
# Provides a mapping between ISO639-1 language codes and language names
# in native languages. Native language names are in order of common
# usage. (e.g. zh-Hant => 繁體中文)
#
# Locale-Name data is stored in:
#   root/config/i18n/locale_name_map.csv
#
# Locale-Name csv columns:
#
#   ISO639-1 Language Code,
#   Language name in English (not used in processing),
#   Language name(s) in native language
#
#   First Language name code always reflects the official language of country
#   (but might not be only official language, e.g. CH).
#
#
# Sources considered:
#   http://people.w3.org/rishida/names/languages.html
#   http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
#   http://en.wikipedia.org/ Languages
#

class RequestInfo::LocaleNameMap
  include Singleton
  attr_accessor :lc

  def initialize
    @lc = {}
    @path = RequestInfo.config.locale_name_map_path

    import_locale_name_map
  end

  VALID_ISO639_CODE_REGEX = /^[a-zA-Z\-]*$/

  def import_locale_name_map
    print "[request_info] importing locale-name map... "

    # read in locale name map file
    CSV.foreach(
      @path,
      # is a Unicode16LE file
      "r:UTF-16LE:UTF-8"
    ) do |row|

      next if row.empty?

      # skip the header row and invalid language codes
      next unless row.first.downcase.match VALID_ISO639_CODE_REGEX

      lcode = row[0].strip.downcase.to_sym
      ename = row[1].strip
      names = row[2..-1].reject(&:nil?).map(&:strip)
      @lc[lcode] = {
        native: names,
        en: ename
      }

    end

    puts "Done."
  end

  # Provide full data from longest matching code language name
  def language_names(locale_code)
    val = nil

    s = locale_code.to_s.downcase.split("-")
    (s.length - 1).downto(0) do |x|
      key = s[0..x].join("-")
      val = language_name_lookup(key)
      break if val
    end

    val
  end

  # Provide only native name after longest matching code language
  # name
  def native_name(locale_code)
    val = language_names(locale_code)
    val = val[:native].first if val

    val
  end

  # Provide only English name after longest matching code language
  # name
  def english_name(locale_code)
    val = language_names(locale_code)
    val = val[:en] if val

    val
  end

  # Directly looks up language name from language code
  # Internal method.
  def language_name_lookup(l)
    @lc[l.downcase.to_sym]
  end

end

