# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

RSpec.describe RequestInfo do
  it "has a version number" do
    expect(RequestInfo::VERSION).not_to be nil
  end

  describe "gem configuration" do
    # Stub the RequestInfo module, and clear its class variables.
    # As a consequence these tests:
    # - do not affect other ones
    # - are not affected by suite-wide gem configuration
    before do
      class_duplicate = RequestInfo.dup
      class_duplicate.instance_variables.each do |ivar|
        class_duplicate.remove_instance_variable(ivar)
      end
      stub_const "RequestInfo", class_duplicate
    end

    example "when ::configure has not been called, ::configuration returns " +
      "an immutable frozen Configuration instance with default settings" do

      retval = RequestInfo.configuration
      expect(retval).to be_a(RequestInfo::Configuration) & be_frozen
      %i[locale_name_map_path locale_map_path geoip2_db_path].each do |attr_name|
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
        c.geoip2_db_path = "some/path"
        expect(c.geoip2_db_path).to eq("some/path")
      end
      current_conf = RequestInfo.configuration
      expect(current_conf).to be_a(RequestInfo::Configuration) & be_frozen
      expect(current_conf.geoip2_db_path).to eq("some/path")
    end

    example "::configure may be called multiple times" do
      RequestInfo.configure { |c| c.geoip2_db_path = "some/path" }
      expect(RequestInfo.configuration.geoip2_db_path).to eq("some/path")
      RequestInfo.configure { |c| c.geoip2_db_path = "yet/another/path" }
      expect(RequestInfo.configuration.geoip2_db_path).to eq("yet/another/path")
    end

    example "configuration is thread-safe" do
      threads = (1..3).each.map do |i|
        Thread.new do
          path = "some/path/#{i}"
          RequestInfo.configure do |c|
            c.geoip2_db_path = path
            sleep(0.01)
          end
          expect(RequestInfo.configuration.geoip2_db_path).to eq(path)
        end
      end

      threads.each(&:join)
    end

    example "::configure returns nil" do
      # Prevent unwanted access to mutable configuration
      expect(RequestInfo.configure { |c| c.geoip2_db_path = "path" }).to be(nil)
    end
  end

  describe "::preload" do
    it "preloads GeoIP, and CountryLocaleMap classes" do
      expect(RequestInfo::GeoIP).to receive(:instance)
      described_class.preload
    end
  end
end
