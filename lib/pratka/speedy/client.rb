# frozen_string_literal: true

require "csv"

module Pratka
  module Speedy
    # Authenticated client for the Speedy courier API.
    class Client
      OFFICES_ENDPOINT = "location/office"
      OFFICES_PARAMS = {
        site_id: :siteId,
        site_name: :siteName,
        name: :name,
        limit: :limit,
        office_type: :officeType,
        office_features: :officeFeatures
      }.freeze

      CITIES_ENDPOINT = "location/site/csv" # Speedy wants to add Country ID at the end of the endpoint. Example location/site/csv/100
      COUNTRIES_ENDPOINT = "location/country/csv"

      COMPLEX_ENDPOINT = "location/complex"
      COMPLEX_PARAMS = { site_id: :siteId, name: :name }.freeze

      STREET_ENDPOINT = "location/street"
      STREET_PARAMS = { site_id: :siteId, name: :name }.freeze

      def initialize(username:, password:, language: Speedy.configuration.language, country_id: Speedy.configuration.country_id)
        @username = username
        @password = password
        @language = language
        @country_id = country_id
      end

      # Calls any Speedy endpoint, including ones without a wrapper method.
      def call(endpoint, data = {})
        http.call(endpoint, data)
      end

      # Fetch all offices from Speedy
      # Allowed params:
      # countryId - We automatically add to the params
      # siteId - Site id. Limits the search scope in the set of offices for specified site. If omitted - all country offices are searched
      # siteName - Filters the results by office site name prefix or part of it.
      # name - Search term for office name. Filters the results by office name prefix or part of site name.
      # limit - The number of records to return in response. All records are returned if this parameter is omitted
      # officeType - enum ["OFFICE", "APT"]
      # officeFeatures - enum ["CARD_PAYMENT", "CASH_PAYMENT", "DROP_OFF", "PICK_UP", "CARGO_TYPE_PARCEL", "CARGO_TYPE_PALLET", "CARGO_TYPE_TYRE"][]
      # Returns the parsed JSON response.
      def fetch_offices(**options)
        call(OFFICES_ENDPOINT, map_params(options, OFFICES_PARAMS).merge(countryId: @country_id))
      end

      # Fetch all cities available in Speedy
      # Returns the parsed array of hashes
      def fetch_cities
        fetch_csv("#{CITIES_ENDPOINT}/#{@country_id}")
      end

      # Fetch all countries available in Speedy
      # Returns the parsed array of hashes
      def fetch_countries
        fetch_csv(COUNTRIES_ENDPOINT)
      end

      # List all complexes in Speedy
      # Allowed params:
      # site_id - Mandatory
      # name - Search term for complex name. Filters the results by complex name prefix or part of complex name.
      def find_complex(**options)
        call(COMPLEX_ENDPOINT, map_params(options, COMPLEX_PARAMS, required: [:site_id]))
      end

      # List all streets in Speedy
      # Allowed params:
      # site_id - Mandatory
      # name - Search term for street name. Filters the results by street name prefix or part of street name.
      def find_street(**options)
        call(STREET_ENDPOINT, map_params(options, STREET_PARAMS, required: [:site_id]))
      end

      private

      def map_params(options, mapping, required: [])
        unknown = options.keys - mapping.keys
        raise ArgumentError, "Unknown params: #{unknown.join(", ")}" if unknown.any?

        missing = required.select { |key| options[key].nil? }
        raise ArgumentError, "Missing params: #{missing.join(", ")}" if missing.any?

        options.transform_keys(mapping)
      end

      def fetch_csv(endpoint)
        result = call(endpoint)
        raise Error, "Expected CSV from #{endpoint}, got #{result.class}" unless result.is_a?(String)

        CSV.parse(result.delete_prefix("﻿").strip, headers: true).map(&:to_h)
      end

      def http
        @http ||= HTTP.new(@username, @password, @language)
      end
    end
  end
end
