# frozen_string_literal: true

module Pratka
  module Speedy
    class Configuration
      attr_writer :base_url, :language, :country_id
      attr_accessor :read_timeout, :open_timeout

      DEFAULT_BASE_URL = "https://api.speedy.bg/v1/"
      DEFAULT_LANGUAGE = "BG"
      DEFAULT_COUNTRY_ID = 100
      DEFAULT_READ_TIMEOUT = 30
      DEFAULT_OPEN_TIMEOUT = 10

      def initialize
        @base_url = DEFAULT_BASE_URL
        @language = DEFAULT_LANGUAGE
        @country_id = DEFAULT_COUNTRY_ID
        @read_timeout = DEFAULT_READ_TIMEOUT
        @open_timeout = DEFAULT_OPEN_TIMEOUT
      end

      def base_url
        Util::StringHelper.nil_or_value(@base_url) || DEFAULT_BASE_URL
      end

      def language
        return @language if ["BG", "EN"].include?(@language)

        DEFAULT_LANGUAGE
      end

      def country_id
        Util::StringHelper.nil_or_value(@country_id) || DEFAULT_COUNTRY_ID
      end
    end
  end
end
