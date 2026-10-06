# frozen_string_literal: true

RSpec.describe Pratka::Speedy::Client do
  subject(:client) { described_class.new(username: "user", password: "secret") }

  let(:http) { instance_double(Pratka::Speedy::HTTP, call: []) }

  before { allow(Pratka::Speedy::HTTP).to receive(:new).and_return(http) }

  it "language is set to default, when not allowed value is assigned" do
    language_client = described_class.new(username: "user", password: "secret", language: "EU")

    language = language_client.instance_variable_get(:@language)
    expect(language).to eq("BG")
  end

  describe "#fetch_offices" do
    it "renames params to camelCase and adds the country" do
      client.fetch_offices(site_id: 68_134, office_type: "APT")

      expect(http).to have_received(:call)
        .with("location/office", { siteId: 68_134, officeType: "APT", countryId: 100 })
    end

    it "rejects unknown params" do
      expect { client.fetch_offices(city: "Sofia") }
        .to raise_error(ArgumentError, "Unknown params: city")
    end
  end

  describe "#find_street" do
    it "requires site_id" do
      expect { client.find_street(name: "Vitosha") }
        .to raise_error(ArgumentError, "Missing params: site_id")
    end
  end

  describe "#fetch_cities" do
    it "parses CSV into hashes and strips the byte order mark" do
      allow(http).to receive(:call)
        .with("location/site/csv/100", {})
        .and_return("\uFEFFid,name\n68134,SOFIA\n")

      expect(client.fetch_cities).to eq([{ "id" => "68134", "name" => "SOFIA" }])
    end

    it "raises when the response is not CSV" do
      expect { client.fetch_cities }.to raise_error(Pratka::Speedy::Error, /Expected CSV/)
    end
  end
end
