# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

RSpec.describe RequestInfo::Configuration do
  it { is_expected.to respond_to(:geoip2_db_path) }
  it { is_expected.to respond_to(:geoip2_db_path=) }

  describe "defaults" do
    example do
      val = subject.geoip2_db_path
      expect(val).to be(nil)
    end
  end
end
