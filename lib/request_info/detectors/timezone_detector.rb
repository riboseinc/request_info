require "active_support/time"

module RequestInfo
  module Detectors
    # Detects Timezone related information
    module TimezoneDetector
      def analyze(_env)
        super

        results = RequestInfo.results
        tzinfo_id, tzinfo = get_tzinfo_from_ipinfo(results.ipinfo)
        return nil unless tzinfo_id && tzinfo

        # Total offset is UTC + DST
        total_offset = tzinfo.current_period.utc_total_offset / 3600.0

        results.timezone = tzinfo
        results.timezone_id = tzinfo_id
        results.timezone_offset = total_offset
        # TODO: i18n this
        results.timezone_desc = "GMT(#{total_offset > 0 ? '+' : ''}#{total_offset}) " +
          "#{tzinfo.friendly_identifier}"

        results
      end

      private

      def get_tzinfo_from_ipinfo(ipinfo)
        # Timezone found in GeoIP.
        tzinfo_id = ipinfo && ipinfo["time_zone"]
        tzinfo = tzinfo_id && TZInfo::Timezone.get(tzinfo_id)
        tzinfo ? [tzinfo_id, tzinfo] : nil
      rescue TZInfo::InvalidTimezoneIdentifier
        nil
      end
    end
  end
end
