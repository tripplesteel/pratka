# frozen_string_literal: true

module Pratka
  module Speedy
    class Configuration
      attr_accessor :base_url, :language, :country_id, :read_timeout, :open_timeout

      def initialize
        @base_url = "https://api.speedy.bg/v1/"
        @language = "BG"
        @country_id = 100 # Bulgaria
        @read_timeout = 30
        @open_timeout = 10
      end
    end
  end
end
