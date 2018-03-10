# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"
require "action_dispatch/middleware/remote_ip"
require "rails"

RSpec.describe RequestInfo::Detectors::IpDetector do
  let(:detected) { RequestInfo.results }

  let(:env) { { "REMOTE_ADDR" => proxy_1, "HTTP_X_FORWARDED_FOR" => h_xff } }
  let(:h_xff) { [ip_spoof, iana_org_ip, nask_pl_ip, proxy_2].join(", ") }
  let(:proxy_1) { "::1" }
  let(:proxy_2) { "192.168.99.1" }
  let(:ip_spoof) { iso_org_ip }

  # iana.org is registered in Los Angeles, US
  let(:iana_org_ip) { "192.0.32.8" }
  let(:iana_org_country_code) { "US" }
  let(:iana_org_city) { "Los Angeles" }

  # nask.pl is registered in Warsaw, Poland
  let(:nask_pl_ip) { "195.187.242.157" }
  let(:nask_pl_country_code) { "PL" }
  let(:nask_pl_city) { "Warsaw" }

  # iso.org is registered in Vernier, Geneva, Switzerland
  let(:iso_org_ip) { "138.81.11.132" }
  let(:iso_org_country_code) { "CH" }
  let(:iso_org_city) { "Vernier, Geneva" }

  # Following IP is reserved and no one will ever register it.
  # See full list at: https://en.wikipedia.org/wiki/Reserved_IP_addresses
  let(:reserved_ip) { "198.51.100.16" }

  shared_context "ip examples" do
    it "detects user IP address" do
      expectations_on_inner_app do
        expect(detected.ip).to eq(expected_ip)
      end
      make_request(env)
    end

    it "finds IP geographical location" do
      skip "GeoIP2 has been purposely disabled" if ENV["DISABLE_GEOIP2"]
      expectations_on_inner_app do
        expect(detected.ipinfo["country_code"]).to eq(expected_country_code)
        expect(detected.ipinfo["city"]).to eq(expected_city)
      end
      make_request(env)
    end
  end

  context "when ActionDispatch::RemoteIp is available" do
    before do
      rack_stack_builder.unshift(
        ActionDispatch::RemoteIp,
        false, # don't raise exception on IP spoofing attempt
        nask_pl_ip, # add IP to trusted proxies
      )
    end

    # Rightmost untrusted proxy in XFF header
    let(:expected_ip) { iana_org_ip }
    let(:expected_country_code) { iana_org_country_code }
    let(:expected_city) { iana_org_city }

    include_examples "ip examples"
  end

  context "when ActionDispatch::RemoteIp is unavailable" do
    # Rightmost untrusted proxy in XFF header
    let(:expected_ip) { nask_pl_ip }
    let(:expected_country_code) { nask_pl_country_code }
    let(:expected_city) { nask_pl_city }

    include_examples "ip examples"
  end
end
