# frozen_string_literal: true

RSpec.describe Pratka::Speedy::APIError do
  it "reads the fields from Speedy's error hash" do
    error = described_class.new({ "message" => "Invalid site", "code" => 1, "context" => "siteId", "id" => "abc" })

    expect(error).to have_attributes(message: "Invalid site", code: 1, context: "siteId", id: "abc")
  end

  it "accepts a plain string" do
    expect(described_class.new("boom").message).to eq("boom")
  end

  it "falls back to a generic message" do
    expect(described_class.new({}).message).to eq("Speedy API error")
  end

  it "can be rescued as Pratka::Error" do
    expect(described_class.new("x")).to be_a(Pratka::Error)
  end
end
