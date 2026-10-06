# frozen_string_literal: true

module Pratka
  module Util
    module StringHelper
      class << self
        def nil_or_value(value)
          (value.nil? || value.to_s.strip.empty?) ? nil : value
        end

        def present?(value)
          !(value.nil? || value.to_s.strip.empty?)
        end
      end
    end
  end
end
