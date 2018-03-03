require "active_support/time"

module RequestInfo
  module Detectors
    # Detects Timezone related information
    module TimezoneDetector
      def analyze(_env)
        super

        results = RequestInfo.results
        tzinfo_id, tzinfo = get_tzinfo_from_ipinfo(results.ipinfo)
        return unless tzinfo_id && tzinfo

        results.timezone = tzinfo
        results.timezone_id = tzinfo_id
        results.timezone_offset = calculate_utc_offset(tzinfo)
        results.timezone_desc = tz_description(tzinfo)
      end

      private

      # Return time zone identifier and object basing on what has been found by
      # GeoIP.
      def get_tzinfo_from_ipinfo(ipinfo)
        tzinfo_id = ipinfo && ipinfo["time_zone"]
        tzinfo = tzinfo_id && TZInfo::Timezone.get(tzinfo_id)
        tzinfo ? [tzinfo_id, tzinfo] : nil
      rescue TZInfo::InvalidTimezoneIdentifier
        nil
      end

      # Total offset is UTC + DST
      def calculate_utc_offset(tzinfo)
        tzinfo.current_period.utc_total_offset / 3600.0
      end

      # TODO: i18n this
      def tz_description(tzinfo)
        offset = calculate_utc_offset(tzinfo)
        offset_string = "#{offset > 0 ? '+' : ''}#{offset}"
        "GMT(#{offset_string}) #{tzinfo.friendly_identifier}"
      end
    end
  end
end
