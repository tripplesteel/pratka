# frozen_string_literal: true

require_relative "../error"

module Pratka
  module Speedy
    class Error < Pratka::Error; end
    class TimeoutError < Error; end
    class ConnectionError < Error; end

    class HTTPError < Error
      attr_reader :status, :body

      def initialize(status, body)
        @status = status
        @body = body
        super("Speedy returned HTTP #{status}")
      end
    end

    class APIError < Error
      attr_reader :code, :context, :id

      def initialize(error)
        error = { "message" => error.to_s } unless error.is_a?(Hash)

        @code = error["code"]
        @context = error["context"]
        @id = error["id"]
        super(error["message"] || "Speedy API error")
      end
    end
  end
end
