require "spec_helper"

RSpec.describe RequestInfo::Configuration do
  it { is_expected.to respond_to(:locale_name_map_path) }
  it { is_expected.to respond_to(:locale_name_map_path=) }
  it { is_expected.to respond_to(:locale_map_path) }
  it { is_expected.to respond_to(:locale_map_path=) }
  it { is_expected.to respond_to(:geoipdb_path) }
  it { is_expected.to respond_to(:geoipdb_path=) }

  describe "defaults" do
    example do
      val = subject.locale_name_map_path
      expect(val).to point_to_existing_file & end_with(".csv")
    end

    example do
      val = subject.locale_map_path
      expect(val).to point_to_existing_file & end_with(".csv")
    end

    example do
      val = subject.geoipdb_path
      expect(val).to be(nil)
    end
  end
end
