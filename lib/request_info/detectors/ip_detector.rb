require "request_info/detectors/base"
require "request_info/geoip"

# Detects IP related information
class RequestInfo::Detectors::IpDetector < RequestInfo::Detectors::Base
  def detect(env)
    ip = request_ip(env)

    {
      ip: ip,
      ipinfo: RequestInfo::GeoIP.lookup(ip),
    }
  end

  private

  # Extracts the IP address from env
  #
  def request_ip(env)
    # TODO: for testing, write tests
    # return '203.198.150.195'

    # Better way to look for the IP most likely to be the address of the actual remote client making this request.
    # This method is provided by ActionDispatch::RemoteIp middleware
    # This middleware assumes that there is at least one proxy sitting around and setting headers with the client's remote IP address.
    # IF YOU DON'T USE A PROXY, THIS MAKES YOU VULNERABLE TO IP SPOOFING.
    return env["action_dispatch.remote_ip"].calculate_ip if env["action_dispatch.remote_ip"]

    if env["HTTP_X_FORWARDED_FOR"]
      # The old way, getting the first IP off X_FORWARDED_FOR stack (env['HTTP_X_FORWARDED_FOR'].split(',').first), would leave us with a security hole
      # so get the entire stack instead.
      # ref: http://www.xyu.io/2013/07/proxies-ip-spoofing/
      return env["HTTP_X_FORWARDED_FOR"]
    end

    env["REMOTE_ADDR"]
  end
end
