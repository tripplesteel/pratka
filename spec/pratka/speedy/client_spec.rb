# frozen_string_literal: true

require "date"

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
      client.fetch_offices(site_id: 68_134, office_type: ["APT"])

      expect(http).to have_received(:call)
        .with("location/office", { siteId: 68_134, officeType: ["APT"], countryId: 100 })
    end

    it "rejects unknown params" do
      expect { client.fetch_offices(city: "Sofia") }
        .to raise_error(ArgumentError, "Unknown params: city")
    end
  end

  describe "#fetch_streets" do
    it "requires site_id" do
      expect { client.fetch_streets(name: "Vitosha") }
        .to raise_error(ArgumentError, "Missing params: site_id")
    end

    it "treats blank values as missing", :aggregate_failures do
      ["", "  ", [], {}].each do |blank|
        expect { client.fetch_streets(site_id: blank) }
          .to raise_error(ArgumentError, "Missing params: site_id")
      end
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

  describe "#print_label" do
    let(:parcels) { [{ parcel: { id: "123" } }] }

    # Real PDFs open with a binary comment line. HTTP hands it back labeled UTF-8

    let(:pdf) { "%PDF-1.5\n%\xE2\xE3\xCF\xD3\n" }
    let(:print_options) { { format: "pdf", printer_name: "Zebra", dpi: "dpi300", sender_copy: "ON_SAME_PAGE" } }
    let(:speedy_options) do
      { format: "pdf", printerName: "Zebra", dpi: "dpi300", additionalWaybillSenderCopy: "ON_SAME_PAGE" }
    end

    before { allow(http).to receive(:call).and_return(pdf) }

    it "sends camelCase params to the print endpoint" do
      client.print_label(paper_size: "A6", parcels: parcels, **print_options)

      expect(http).to have_received(:call)
        .with("print", { paperSize: "A6", parcels: parcels, **speedy_options })
    end

    it "returns the label as binary bytes", :aggregate_failures do
      label = client.print_label(paper_size: "A6", parcels: parcels)

      expect(label).to eq(pdf.b)
      expect(label.encoding).to eq(Encoding::BINARY)
      expect(label).to be_valid_encoding
    end

    it "raises when Speedy returns an empty label" do
      allow(http).to receive(:call).and_return("")

      expect { client.print_label(paper_size: "A6", parcels: parcels) }
        .to raise_error(Pratka::Speedy::Error, /empty label/)
    end

    it "rejects empty parcels without calling Speedy", :aggregate_failures do
      expect { client.print_label(paper_size: "A6", parcels: []) }
        .to raise_error(ArgumentError, "Missing params: parcels")
      expect(http).not_to have_received(:call)
    end
  end

  describe "#fetch_payment_details" do
    it "sends camelCase params to the payments endpoint" do
      client.fetch_payment_details(from_date: "2026-10-01T00:00:00+0300", to_date: "2026-10-07T23:59:59+0300",
                                   include_details: true)

      expect(http).to have_received(:call)
        .with("payments", { fromDate: "2026-10-01T00:00:00+0300", toDate: "2026-10-07T23:59:59+0300",
                            includeDetails: true })
    end

    it "formats DateTime and Time with their offset" do
      client.fetch_payment_details(from_date: DateTime.new(2026, 10, 1, 9, 0, 0, "+03:00"),
                                   to_date: Time.new(2026, 10, 7, 18, 30, 15, "+03:00"))

      expect(http).to have_received(:call)
        .with("payments", { fromDate: "2026-10-01T09:00:00+0300", toDate: "2026-10-07T18:30:15+0300" })
    end

    it "formats Date as midnight UTC" do
      client.fetch_payment_details(from_date: Date.new(2026, 10, 1), to_date: Date.new(2026, 10, 7))

      expect(http).to have_received(:call)
        .with("payments", { fromDate: "2026-10-01T00:00:00+0000", toDate: "2026-10-07T00:00:00+0000" })
    end

    it "requires from_date and to_date without calling Speedy", :aggregate_failures do
      expect { client.fetch_payment_details(include_details: true) }
        .to raise_error(ArgumentError, "Missing params: from_date, to_date")
      expect(http).not_to have_received(:call)
    end
  end

  describe "#create_shipment" do
    let(:shipment) do
      {
        recipient: { phone1: { number: "0899445566" }, clientName: "Ivan Ivanov", pickupOfficeId: 77 },
        service: { serviceId: 505, autoAdjustPickupDate: true },
        content: { parcelsCount: 1, totalWeight: 0.6, contents: "Phone", package: "BOX" },
        payment: { courierServicePayer: "RECIPIENT" }
      }
    end

    it "sends camelCase params to the shipment endpoint and keeps nested hashes as they are" do
      sender = { clientId: 1_234_567_890 }

      client.create_shipment(sender: sender, shipment_note: "Fragile", **shipment)

      expect(http).to have_received(:call)
        .with("shipment", { sender: sender, shipmentNote: "Fragile", **shipment })
    end

    it "returns the parsed response" do
      response = { "id" => "299999990", "parcels" => [{ "seqNo" => 1, "id" => "299999990" }] }
      allow(http).to receive(:call).and_return(response)

      expect(client.create_shipment(**shipment)).to eq(response)
    end

    it "requires recipient, service, content and payment without calling Speedy", :aggregate_failures do
      expect { client.create_shipment(shipment_note: "Fragile") }
        .to raise_error(ArgumentError, "Missing params: recipient, service, content, payment")
      expect(http).not_to have_received(:call)
    end

    it "treats an empty nested hash as missing" do
      expect { client.create_shipment(**shipment, payment: {}) }
        .to raise_error(ArgumentError, "Missing params: payment")
    end

    it "rejects unknown params" do
      expect { client.create_shipment(**shipment, ref1: "ORDER-1001") }
        .to raise_error(ArgumentError, "Unknown params: ref1")
    end
  end
end
