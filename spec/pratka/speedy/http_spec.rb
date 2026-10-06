# frozen_string_literal: true

RSpec.describe Pratka::Speedy::HTTP do
  subject(:http) { described_class.new("user", "secret", "BG") }

  let(:url) { "https://api.speedy.bg/v1/location/office" }
  let(:json) { { "Content-Type" => "application/json" } }

  it "sends credentials merged into the JSON body" do
    stub = stub_request(:post, url)
           .with(body: { userName: "user", password: "secret", language: "BG", siteId: 1 })
           .to_return(body: "[]", headers: json)

    http.call("location/office", { siteId: 1 })

    expect(stub).to have_been_requested
  end

  it "returns parsed JSON" do
    stub_request(:post, url).to_return(body: '{"offices":[]}', headers: json)

    expect(http.call("location/office", {})).to eq({ "offices" => [] })
  end

  it "returns the raw body when the response is not JSON" do
    stub_request(:post, url).to_return(body: "id,name\n", headers: { "Content-Type" => "text/csv" })

    expect(http.call("location/office", {})).to eq("id,name\n")
  end

  it "raises APIError when the JSON contains an error" do
    stub_request(:post, url).to_return(body: '{"error":{"message":"Bad login","code":5}}', headers: json)

    expect { http.call("location/office", {}) }
      .to raise_error(Pratka::Speedy::APIError, "Bad login")
  end

  it "raises HTTPError on a non-2xx status" do
    stub_request(:post, url).to_return(status: 500, body: "oops")

    expect { http.call("location/office", {}) }
      .to raise_error(an_instance_of(Pratka::Speedy::HTTPError).and(having_attributes(status: 500, body: "oops")))
  end

  it "puts the response body in the HTTPError message" do
    stub_request(:post, url).to_return(status: 400, body: "Cannot deserialize\n at line 1")

    expect { http.call("location/office", {}) }
      .to raise_error(Pratka::Speedy::HTTPError, "Speedy returned HTTP 400: Cannot deserialize at line 1")
  end

  it "truncates a long body in the HTTPError message" do
    stub_request(:post, url).to_return(status: 400, body: "x" * 300)

    expect { http.call("location/office", {}) }
      .to raise_error(Pratka::Speedy::HTTPError, "Speedy returned HTTP 400: #{"x" * 200}...")
  end

  it "wraps timeouts" do
    stub_request(:post, url).to_timeout

    expect { http.call("location/office", {}) }.to raise_error(Pratka::Speedy::TimeoutError)
  end

  it "wraps connection failures" do
    stub_request(:post, url).to_raise(SocketError)

    expect { http.call("location/office", {}) }.to raise_error(Pratka::Speedy::ConnectionError)
  end

  describe "empty response body" do
    it "returns an empty string on 204 No Content" do
      stub_request(:post, url).to_return(status: 204)

      expect(http.call("location/office", {})).to eq("")
    end

    it "returns an empty string on 200 with no body" do
      stub_request(:post, url).to_return(status: 200, body: "")

      expect(http.call("location/office", {})).to eq("")
    end

    it "raises HTTPError with an empty body on a 5xx with no body" do
      stub_request(:post, url).to_return(status: 502)

      expect { http.call("location/office", {}) }
        .to raise_error(an_instance_of(Pratka::Speedy::HTTPError).and(having_attributes(status: 502, body: "", message: "Speedy returned HTTP 502")))
    end

    it "raises Error when a JSON response has no body" do
      stub_request(:post, url).to_return(status: 200, body: "", headers: json)

      expect { http.call("location/office", {}) }
        .to raise_error(Pratka::Speedy::Error, /Invalid JSON/)
    end
  end

  describe "body encoding" do
    it "labels binary bodies as UTF-8" do
      stub_request(:post, url).to_return(body: "София".b, headers: { "Content-Type" => "text/csv" })

      expect(http.call("location/office", {}))
        .to eq("София").and(have_attributes(encoding: Encoding::UTF_8))
    end

    it "parses Cyrillic JSON from a binary body" do
      stub_request(:post, url).to_return(body: '{"name":"София"}'.b, headers: json)

      expect(http.call("location/office", {})).to eq({ "name" => "София" })
    end
  end
end
