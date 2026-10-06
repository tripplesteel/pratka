# frozen_string_literal: true

RSpec.describe Pratka::Speedy do
  after { described_class.instance_variable_set(:@configuration, nil) }

  it "applies changes made inside configure" do
    described_class.configure { |c| c.language = "EN" }

    expect(described_class.configuration.language).to eq("EN")
  end

  it "returns the same object on every call" do
    first = described_class.configuration

    expect(described_class.configuration).to be(first)
  end
end
