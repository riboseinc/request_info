require "spec_helper"

RSpec.describe RequestInfo::TimezoneDetector do
  let(:detected) { RequestInfo.results }

  # Freeze time in winter to avoid any possible DST issues.
  before { Timecop.freeze 2018, 1 }

  it "is a singleton" do
    expect(described_class).to respond_to(:instance)
    expect(described_class.instance).to be_a(described_class)
    expect(described_class.instance).to be(described_class.instance)
  end

  shared_context "time zone examples" do |time_zone_description|
    before do
      # expect(RequestInfo::Results).to receive(:new)
      # binding.pry
      allow_any_instance_of(RequestInfo::Results).to receive(:ipinfo).and_return(ipinfo)
    end

    it "detects #{time_zone_description} time zone identifier" do
      expectations_on_inner_app do
        expect(detected.timezone_id).to eq(expected_timezone_id)
      end
      make_request({})
    end

    it "detects #{time_zone_description} time zone offset" do
      expectations_on_inner_app do
        expect(detected.timezone_offset).to eq(expected_timezone_offset)
      end
      make_request({})
    end

    it "detects #{time_zone_description} time zone description" do
      expectations_on_inner_app do
        expect(detected.timezone_desc).to eq(expected_timezone_description)
      end
      make_request({})
    end

    it "sets #{time_zone_description} TzInfo object" do
      expectations_on_inner_app do
        expect(detected.timezone).to eq(expected_timezone_object)
      end
      make_request({})
    end
  end

  context "when IP location couldn't be determined" do
    let(:ipinfo) { nil }
    let(:expected_timezone_id) { nil }
    let(:expected_timezone_offset) { nil }
    let(:expected_timezone_description) { nil }
    let(:expected_timezone_object) { nil }

    include_examples "time zone examples", "no"
  end

  context "when IP location could be determined, but time zone info " +
    "is missing (like when using GeoIP lite data base)" do
    let(:ipinfo) { { "country" => "Poland", "country_code" => "PL" } }
    let(:expected_timezone_id) { nil }
    let(:expected_timezone_offset) { nil }
    let(:expected_timezone_description) { nil }
    let(:expected_timezone_object) { nil }

    include_examples "time zone examples", "no"
  end

  context "when IP location and time zone have been determined" do
    let(:ipinfo) { { "country" => "Poland", "country_code" => "PL", "time_zone" => expected_timezone_id } }
    let(:expected_timezone_id) { "Europe/Warsaw" }
    let(:expected_timezone_offset) { 1.0 }
    let(:expected_timezone_description) { "GMT(+1.0) Europe - Warsaw" }
    let(:expected_timezone_object) { TZInfo::Timezone.get("Europe/Warsaw") }

    include_examples "time zone examples", "correct"
  end
end
