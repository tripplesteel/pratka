# frozen_string_literal: true

RSpec.describe Pratka::Speedy::Configuration do
  subject(:config) { described_class.new }

  describe "Base URL" do
    it "points at the Speedy v1 API" do
      expect(config.base_url).to eq("https://api.speedy.bg/v1/")
    end

    it "nil base_url returns Speedy V1 API" do
      config.base_url = nil

      expect(config.base_url).to eq("https://api.speedy.bg/v1/")
    end

    it "blank base_url returns Speedy V1 API" do
      config.base_url = ""

      expect(config.base_url).to eq("https://api.speedy.bg/v1/")
    end
  end

  describe "Timeouts" do
    it "read_timeout changes" do
      config.read_timeout = 45

      expect(config.read_timeout).to eq(45)
    end

    it "open_timeout changes" do
      config.open_timeout = 15

      expect(config.open_timeout).to eq(15)
    end

    it "read_timeout is allowed to be nil" do
      config.read_timeout = nil

      expect(config.read_timeout).to be_nil
    end

    it "open_timeout is allowed to be nil" do
      config.open_timeout = nil

      expect(config.open_timeout).to be_nil
    end
  end

  describe "Language" do
    it "defaults to Bulgarian and Bulgaria" do
      expect(config).to have_attributes(language: "BG", country_id: 100)
    end

    it "language can be changed to EN" do
      config.language = "EN"

      expect(config.language).to eq("EN")
    end

    it "language can't be nil" do
      config.language = nil

      expect(config.language).to eq("BG")
    end

    it "language doesn't allow other values than BG or EN" do
      config.language = "EU"

      expect(config.language).to eq("BG")
    end

    it "language can't be blank" do
      config.language = ""

      expect(config.language).to eq("BG")
    end
  end
end
