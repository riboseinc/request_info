require "spec_helper"

RSpec.describe RequestInfo do
  it "has a version number" do
    expect(RequestInfo::VERSION).not_to be nil
  end

  describe "gem configuration" do
    example "when ::configure has not been called, ::configuration returns " +
      "an immutable frozen Configuration instance with default settings" do

      retval = RequestInfo.configuration
      expect(retval).to be_a(RequestInfo::Configuration) & be_frozen
      %i[locale_name_map_path locale_map_path geoip_path].each do |attr_name|
        attr_val = retval.send(attr_name)
        attr_default = RequestInfo::Configuration.new.send(attr_name)
        expect(attr_val).to eq(attr_default)
      end
    end

    example "::configure yields a mutable configuration object, as it allows " +
      "to alter conifguration, which can be later accessed read-only " +
      "via ::configuration" do

      RequestInfo.configure do |c|
        expect(c).to be_a(RequestInfo::Configuration)
        c.geoip_path = "some/path"
        expect(c.geoip_path).to eq("some/path")
      end
      current_conf = RequestInfo.configuration
      expect(current_conf).to be_a(RequestInfo::Configuration) & be_frozen
      expect(current_conf.geoip_path).to eq("some/path")
    end

    example "::configure may be called multiple times" do
      RequestInfo.configure { |c| c.geoip_path = "some/path" }
      RequestInfo.configure { |c| c.locale_map_path = "different/path" }
      expect(RequestInfo.configuration.geoip_path).to eq("some/path")
      expect(RequestInfo.configuration.locale_map_path).to eq("different/path")
      RequestInfo.configure { |c| c.geoip_path = "yet/another/path" }
      expect(RequestInfo.configuration.geoip_path).to eq("yet/another/path")
      expect(RequestInfo.configuration.locale_map_path).to eq("different/path")
      RequestInfo.configure { |c| c.locale_map_path = "final/path" }
      expect(RequestInfo.configuration.geoip_path).to eq("yet/another/path")
      expect(RequestInfo.configuration.locale_map_path).to eq("final/path")
    end
  end
end
