# (c) Copyright 2017 Ribose Inc.
#

require "csv"
require "singleton"
require "request_info/configuration"

#
# Provides a mapping between ISO3166 country codes and RFC4646 locale
# codes. Locale codes are placed in order of usage in the region
# (e.g. de-CH > fr-CH > it-CH).
#
# Country-Locale data is stored in:
#   root/config/i18n/country_locale_map.csv
#
# Country-Locale csv columns:
#
#   ISO3166 Country Code,
#   Country name, (not used in processing)
#   RFC4646 Locale code,
#   (all columns after are RFC4646 Locale codes)
#
#   RFC4646 Locale codes are ordered to indicate preference.
#   i.e. locale code in column 3 is more important than the locale code
#   in column 5 for a country.
#
#   First Locale code always reflects the official language of country
#   (but might not be only official language, e.g. CH).
#
#
# Sources considered:
#   http://www.i18nguy.com/unicode/language-identifiers.html
#   http://www.infoplease.com/ipa/A0855611.html
#

#
# TODO: Give each locale a preference value: e.g. de-CH 0.6, fr-CH 0.3
#
class RequestInfo::CountryLocaleMap
  include Singleton
  attr_accessor :cc, :ll

  DEFAULT_COUNTRY_CODE = "us".freeze
  DEFAULT_LOCALE_CODE = "en-us".freeze

  def initialize
    @cc = {}
    @ll = {}
    @path = RequestInfo.configuration.locale_map_path

    import_locale_map
  end

  # Imports country-locale map to memory for upcoming
  # queries
  def import_locale_map
    print "[request_info] importing country-locale map... "

    # read in country locale map file
    CSV.foreach(
      @path,
    ) do |row|
      next if row.empty?

      # skip the header row
      next if row.first.length > 3

      ccode = row[0].strip.downcase.to_sym
      name = row[1].strip
      langs = row[2..-1].reject(&:nil?).map(&:downcase).map(&:strip)
      @cc[ccode] = {
        name: name,
        locales: langs,
      }

      langs.each do |l|
        @ll[l.to_sym] ||= {}
        @ll[l.to_sym][:ccodes] ||= []
        @ll[l.to_sym][:ccodes].push ccode
      end
    end

    puts "Done."
  end

  # Returns an array of country codes that match the given locale code.
  #
  # Note: Since in our current mapping, "en" is not assigned to any
  # country, so "en" will not match anything while "en-us" will return
  # "us".
  #
  def locale_country_codes(l)
    if l.nil? || !@ll.has_key?(l.downcase.to_sym)
      Rails.logger.warn "Unknown locale key: #{l}"
      l = DEFAULT_LOCALE_CODE
    end

    @ll[l.downcase.to_sym][:ccodes]
  end

  # Returns an array of locale ids that match the given country code.
  #
  def country_code_locales(c)
    if c.nil? || !@cc.has_key?(c.downcase.to_sym)
      Rails.logger.warn "Unknown country code: #{c}"
      c = DEFAULT_COUNTRY_CODE
    end

    @cc[c.downcase.to_sym][:locales]
  end
end
