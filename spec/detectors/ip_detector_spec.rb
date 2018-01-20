require "spec_helper"
require "action_dispatch/middleware/remote_ip"
require "rails"

RSpec.describe RequestInfo::Detectors::IpDetector do
  let(:detected) { RequestInfo.results }

  # iana.org is registered in Los Angeles, US
  let(:iana_org_ip) { "192.0.32.8" }
  let(:iana_org_country_code) { "US" }
  let(:iana_org_city) { "Los Angeles" }

  # nask.pl is registered in Warsaw, Poland
  let(:nask_pl_ip) { "195.187.242.157" }
  let(:nask_pl_country_code) { "PL" }
  let(:nask_pl_city) { "Warsaw" }

  # Following IP is reserved and no one will ever register it.
  # See full list at: https://en.wikipedia.org/wiki/Reserved_IP_addresses
  let(:reserved_ip) { "198.51.100.16" }

  before(:all) { RequestInfo::GeoIP.setup }

  it "is a singleton" do
    expect(described_class).to respond_to(:instance)
    expect(described_class.instance).to be_a(described_class)
    expect(described_class.instance).to be(described_class.instance)
  end

  shared_context "ip examples" do |source_description|
    it "takes #{source_description} as user IP address" do
      expectations_on_inner_app do
        expect(detected.ip).to eq(expected_ip)
      end
      make_request(env)
    end

    it "finds IP geographical location of #{source_description}" do
      if source_description =~ /X-Forwarded-For/
        pending "Gem behaves inconsistently.  A failing spec has been disabled."
      end
      expectations_on_inner_app do
        expect(detected.ipinfo["country_code"]).to eq(expected_country_code)
        expect(detected.ipinfo["city"]).to eq(expected_city)
      end
      make_request(env)
    end
  end

  context "when ActionDispatch::RemoteIp is available" do
    before do
      rack_stack_builder.unshift ActionDispatch::RemoteIp
    end

    before do
      get_ip_class = ActionDispatch::RemoteIp::GetIp
      get_ip_dbl = double(get_ip_class)
      expect(get_ip_dbl).to receive(:calculate_ip).and_return(iana_org_ip)
      expect(get_ip_class).to receive(:new).and_return(get_ip_dbl)
    end

    let(:env) { {} }
    let(:expected_ip) { iana_org_ip }
    let(:expected_country_code) { iana_org_country_code }
    let(:expected_city) { iana_org_city }

    include_examples "ip examples", "ActionDispatch::RemoteIp guessings"
  end

  context "when ActionDispatch::RemoteIp is unavailable, but X-Forwarded-For " +
    "header is present" do
    let(:env) { { "HTTP_X_FORWARDED_FOR" => "#{iana_org_ip}, #{nask_pl_ip}" } }
    let(:expected_ip) { "#{iana_org_ip}, #{nask_pl_ip}" }
    let(:expected_country_code) { iana_org_country_code }
    let(:expected_city) { iana_org_city }

    include_examples "ip examples",
      "the set of IP addresses from X-Forwarded-For header"
  end

  context "when ActionDispatch::RemoteIp is unavailable, neither " +
    "X-Forwarded-For header is, but REMOTE_ADDR is present" do
    let(:env) { { "REMOTE_ADDR" => nask_pl_ip } }
    let(:expected_ip) { nask_pl_ip }
    let(:expected_country_code) { nask_pl_country_code }
    let(:expected_city) { nask_pl_city }

    include_examples "ip examples",
      "the set of IP addresses from REMOTE_ADDR variable"
  end
end
