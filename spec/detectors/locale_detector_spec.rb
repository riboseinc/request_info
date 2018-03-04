# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

RSpec.describe RequestInfo::Detectors::LocaleDetector do
  let(:default_locale) { :en }
  let(:initial_locale) { :en }
  let(:ipinfo_locale) { :de }
  let(:ipinfo_country_code) { "DE" }
  let(:available_locales) { %i[en pl de cs ro] }

  let(:detected) { RequestInfo.results }
  let(:env_key_name) { "request_info.locale.detected" }
  let(:env) { { "HTTP_ACCEPT_LANGUAGE" => h_accept_language } }

  before do
    ipinfo = ipinfo_country_code && { "country_code" => ipinfo_country_code }
    allow_any_instance_of(RequestInfo::Results).
      to receive(:ipinfo).and_return(ipinfo)
  end

  before do
    # Stub i18n configuration
    allow(I18n.config).to receive(:enforce_available_locales).and_return(false)
    allow(I18n).to receive(:default_locale).and_return(default_locale)
    I18n.locale = initial_locale
    I18n.available_locales = available_locales
  end

  shared_context "locale examples" do |locale_description|
    it "detects #{locale_description} locale" do
      expectations_on_inner_app do
        expect(detected.locale).to eq(expected_locale.to_s)
      end
      make_request(env)
    end

    it "sets locale to #{locale_description} inside the inner app" do
      expectations_on_inner_app do
        expect(I18n.locale.to_s).to eq(expected_locale.to_s)
      end
      make_request(env)
    end

    it "reverts locale after processing the inner app" do
      make_request(env)
      expect(I18n.locale).to be(initial_locale)
    end

    it "sets Content-Language header on response" do
      response = make_request(env)
      expect(response.headers["Content-Language"]).to eq(expected_locale.to_s)
    end
  end

  context "when Accept-Language header is missing" do
    let(:env) { {} }

    context "and preferred language cannot be guessed from client's IP" do
      let(:ipinfo_country_code) { nil }
      let(:expected_locale) { default_locale }
      include_examples "locale examples", "default one"
    end

    context "and preferred language can be guessed from client's IP" do
      let(:expected_locale) { ipinfo_locale }
      include_examples "locale examples", "one matching client's IP"
    end
  end

  context "when Accept-Language header is a weighted array of locales" do
    let(:h_accept_language) { "hu;q=0.9,nb;q=0.7,cs;q=0.8,ro;q=0.5" }
    let(:expected_locale) { :cs }
    include_examples "locale examples",
      "the available one with the highest weight"

    context "and neither of requested languages is available" do
      let(:available_locales) { %i[en pl de] }

      context "and preferred language cannot be guessed from client's IP" do
        let(:ipinfo_country_code) { nil }
        let(:expected_locale) { default_locale }
        include_examples "locale examples", "default one"
      end

      context "and preferred language can be guessed from client's IP" do
        let(:expected_locale) { ipinfo_locale }
        include_examples "locale examples", "one matching client's IP"
      end
    end
  end
end
