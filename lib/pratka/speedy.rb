# frozen_string_literal: true

require_relative "speedy/errors"
require_relative "speedy/configuration"
require_relative "speedy/client"
require_relative "speedy/http"

module Pratka
  module Speedy
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield configuration
      end
    end
  end
end
