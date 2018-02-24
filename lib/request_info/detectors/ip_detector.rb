require "request_info/detectors/base"
require "request_info/geoip"

# Detects IP related information
module RequestInfo
  module Detectors
    # TODO Write some notes on configuration & security in README.
    class IpDetector < Base
      def detect(env)
        ip = request_ip(env)

        {
          ip: ip,
          ipinfo: RequestInfo::GeoIP.instance.lookup(ip),
        }
      end

      private

      # Extracts the IP address from env
      #
      def request_ip(env)
        obtain_ip_from_rails(env) || obtain_ip_from_rack(env)
      end

      # Obtain client's IP address from +ActionDispatch::RemoteIp+ middleware
      # provided by Rails.
      #
      # This is preferred over using +Rack::Request+ because
      # +ActionDispatch::RemoteIp+ middleware must be enabled purposely, and
      # is more customizable (proxies whitelisting is customizable).
      #
      # Please read security notes before enabling +ActionDispatch::RemoteIp+
      # middleware in your application.  It may do harm if used incorrectly:
      # http://api.rubyonrails.org/classes/ActionDispatch/RemoteIp.html
      def obtain_ip_from_rails(env)
        env["action_dispatch.remote_ip"].try(:to_s)
      end

      # Obtain client's IP address from +Rack::Request+.  May return proxy
      # address if it adds a non-private IP address to +X-Forwarded-For+ header.
      #
      # https://github.com/rack/rack/blob/d1363a66ab217/lib/rack/request.rb#L420
      def obtain_ip_from_rack(env)
        Rack::Request.new(env).ip
      end
    end
  end
end
