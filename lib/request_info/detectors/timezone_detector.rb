require "active_support/time"

module RequestInfo
  module Detectors
    # Detects Timezone related information
    module TimezoneDetector
      def analyze(_env)
        super

        results = RequestInfo.results
        ipinfo = results.ipinfo

        # Rails.logger.warn "[request_info] geoip results #{ipinfo.inspect}"

        # Stop processing if no ipinfo
        return results unless ipinfo

        # Timezone found in GeoIP.
        tzinfo_id = ipinfo["time_zone"]
        # Stop processing if no valid timezone
        return results unless tzinfo_id

        tzinfo = TZInfo::Timezone.get(tzinfo_id) rescue nil
        # Stop processing if tzinfo isn't found as a TimeZone
        return results unless tzinfo

        # Rails.logger.warn "[request_info] geoip results tzinfo #{tzinfo}"

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
    end
  end
end
