# frozen_string_literal: true

require "json"
require "net/http"

module Pratka
  module Speedy
    # Net::HTTP class to handle requests to the Speedy API
    class HTTP
      def initialize(username, password, language)
        @username = username
        @password = password
        @language = language
      end

      # Each call opens a fresh connection and closes it when the block exits.
      def call(endpoint, data)
        response = Net::HTTP.start(base_uri.host, base_uri.port, **connection_options) do |http|
          http.request(build_request(endpoint, data))
        end
        body = (+response.body.to_s).force_encoding(Encoding::UTF_8)

        raise HTTPError.new(response.code.to_i, body) unless response.is_a?(Net::HTTPSuccess)
        return body unless json?(response)

        parsed = JSON.parse(body)
        raise APIError.new(parsed["error"]) if parsed.is_a?(Hash) && parsed["error"]

        parsed
      rescue Timeout::Error => e
        raise TimeoutError, e.message
      rescue SocketError, SystemCallError, OpenSSL::SSL::SSLError, EOFError => e
        raise ConnectionError, e.message
      rescue Net::HTTPBadResponse, Zlib::Error => e
        raise Error, "Malformed response from Speedy: #{e.message}"
      rescue JSON::ParserError => e
        raise Error, "Invalid JSON from Speedy: #{e.message}"
      end

      private

      def json?(response)
        response.content_type.to_s.include?("json")
      end

      # Speedy wants credentials in its data payload
      def data_with_credentials(data)
        { userName: @username, password: @password, language: @language }.merge(data)
      end

      def base_uri
        @base_uri ||= URI(safe_base_url)
      end

      def safe_base_url
        url = Speedy.configuration.base_url
        url.end_with?("/") ? url : "#{url}/"
      end

      def connection_options
        {
          use_ssl: base_uri.scheme == "https",
          read_timeout: Speedy.configuration.read_timeout,
          open_timeout: Speedy.configuration.open_timeout
        }
      end

      def build_request(endpoint, data)
        req = Net::HTTP::Post.new(base_uri.path + endpoint, "Content-Type" => "application/json")
        req.body = data_with_credentials(data).to_json

        req
      end
    end
  end
end
