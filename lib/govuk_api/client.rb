require_relative "govuk_headers"
require_relative "exceptions"
require_relative "response"
require "faraday"
require "plek"

module GovukApi
  class Client
    include GovukApi::ExceptionHandling

    DEFAULT_TIMEOUT_IN_SECONDS = 4

    attr_reader :endpoint_url, :options

    def initialize(endpoint_url, options = {})
      raise "The timeout cannot be disabled." if options[:timeout].to_i < 0
      @endpoint_url = endpoint_url
      @options = options
    end

    def get_raw(app, url, params = {}, additional_headers = {})
      # Override the default application/json
      additional_headers["Accept"] = "*/*"
      request(app, url, :get, params, additional_headers)
    end

    def get_json(app, url, params = {}, additional_headers = {})
      json_request(app, url, :get, params, additional_headers)
    end

    def post_json(app, url, params = {}, additional_headers = {})
      json_request(app, url, :post, params, additional_headers)
    end

    def put_json(app, url, params, additional_headers = {})
      json_request(app, url, :put, params, additional_headers)
    end

    def patch_json(app, url, params, additional_headers = {})
      json_request(app, url, :patch, params, additional_headers)
    end

    def delete_json(app, url, additional_headers = {})
      json_request(app, url, :delete, nil, additional_headers)
    end

    def post_multipart(app, url, params, additional_headers = {})
      request(app, url, :post, params, additional_headers, multipart: true)
    end

    def put_multipart(app, url, params, additional_headers = {})
      request(app, url, :put, params, additional_headers, multipart: true)
    end

  private

    def request(app, url, method, params, additional_headers, multipart: false)
      domain = Plek.find(app)

      conn = Faraday.new(url: domain) do |req|
        req.request(:multipart) if multipart
        req.basic_auth(options[:basic_auth][:user], options[:basic_auth][:password]) if options[:basic_auth]
        req.token_auth(options[:bearer_token]) if options[:bearer_token]
        req.adapter(Faraday.default_adapter)
        req.params = params
        req.headers = all_headers.merge(additional_headers)
        req.options.timeout = timeout
        req.options.open_timeout = timeout
      end

      response = conn.send(method, url)

      if response.success?
        Response.new(response)
      else
        raise build_specific_http_error(response)
      end
    rescue Faraday::ConnectionFailed
      raise GovukApi::EndpointNotFound("Could not connect to #{domain}#{url}")
    rescue Faraday::TimeoutError
      raise GovukApi::TimedOutException
    rescue Faraday::ParsingError
      raise GovukApi::InvalidUrl
    end

    def json_request(app, url, method, params, additional_headers)
      additional_headers["Content-Type"] = "application/json" unless params.empty?
      request(app, url, method, params, additional_headers)
    end

    def default_headers
      {
        "Accept" => "application/json",
        "User-Agent" => "govuk_api/#{GovukApi::VERSION} (#{ENV['GOVUK_APP_NAME']})"
      }
    end

    def sniffed_headers
      GovukApi::GovukHeaders.headers
    end

    def all_headers
      default_headers.merge(sniffed_headers)
    end

    def timeout
      options[:timeout] || DEFAULT_TIMEOUT_IN_SECONDS
    end
  end
end
