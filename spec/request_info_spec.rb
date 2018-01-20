require "spec_helper"

RSpec.describe RequestInfo do
  it "has a version number" do
    expect(RequestInfo::VERSION).not_to be nil
  end
end
