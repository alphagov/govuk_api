require_relative "govuk_api/railtie" if defined?(Rails)
require_relative "govuk_api/client"
require_relative "govuk_api/version"

module GovukApi
  class Base
    class InvalidAPIURL < StandardError; end

    attr_reader :endpoint_url, :options

    def initialize(endpoint_url, options = {})
      raise InvalidAPIURL unless endpoint_url =~ URI::RFC3986_Parser::RFC3986_URI
      @endpoint_url = endpoint_url
      @options = options
    end

    def client
      @client ||= GovukApi::Client(endpoint_url, options)
    end
  end
end
