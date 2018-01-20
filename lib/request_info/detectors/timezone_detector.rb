require "request_info/detectors/base"
require "active_support/time"

# Detects Timezone related information
class RequestInfo::Detectors::TimezoneDetector < RequestInfo::Detectors::Base
  def detect(_env)
    ipinfo = RequestInfo.results.ipinfo

    # Rails.logger.warn "[request_info] geoip results #{ipinfo.inspect}"

    # Stop processing if no ipinfo
    return nil_result unless ipinfo && ipinfo["country"]

    # Timezone found in GeoIP.
    tzinfo_id = ipinfo["time_zone"]
    # Stop processing if no valid timezone
    return nil_result unless tzinfo_id

    tzinfo = TZInfo::Timezone.get(tzinfo_id) rescue nil
    # Stop processing if tzinfo isn't found as a TimeZone
    return nil_result unless tzinfo

    # Rails.logger.warn "[request_info] geoip results tzinfo #{tzinfo}"

    # Total offset is UTC + DST
    total_offset = tzinfo.current_period.utc_total_offset / 3600.0

    {
      timezone: tzinfo,
      timezone_id: tzinfo_id,
      timezone_offset: total_offset,
      # TODO: i18n this
      timezone_desc: "GMT(#{total_offset > 0 ? '+' : ''}#{total_offset}) " +
        "#{tzinfo.friendly_identifier}",
    }
  end

  def nil_result
    { timezone: nil }
  end
end
