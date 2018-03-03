require "spec_helper"

RSpec.describe RequestInfo::Detectors::BrowserDetector do
  let(:detected) { RequestInfo.results }
  let(:env) { { "HTTP_USER_AGENT" => h_ua, "HTTP_ACCEPT_LANGUAGE" => h_lang } }
  let(:h_ua) { "example agent" }
  let(:h_lang) { "pl" }

  it "sets results.browser to a browser object" do
    make_request(env)
    expect(detected.browser).to be_a(Browser::Base)
  end

  it "detects client's user agent" do
    make_request(env)
    expect(detected.browser).to be_a(Browser::Base)
    expect(detected.browser.ua).to eq(h_ua)
  end

  it "detects client's accepted languages" do
    make_request(env)
    expect(detected.browser.accept_language).to be_an(Array)
    expect(detected.browser.accept_language[0].code).to eq(h_lang)
  end
end
