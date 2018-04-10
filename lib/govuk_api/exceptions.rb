module GovukApi
  # Abstract error class
  class BaseError < StandardError
    # Give Sentry extra context about this event
    # https://docs.sentry.io/clients/ruby/context/
    def raven_context
      {
        # Make Sentry group exceptions by type instead of message, so all
        # exceptions like `GovukApi::TimedOutException` will get grouped as one
        # error and not an error per URL.
        fingerprint: [self.class.name],
      }
    end
  end

  class EndpointNotFound < BaseError; end
  class TimedOutException < BaseError; end
  class InvalidUrl < BaseError; end

  # Superclass for all 4XX and 5XX errors
  class HTTPErrorResponse < BaseError
    attr_accessor :code, :error_details

    def initialize(code, message = nil, error_details = nil, request_body = nil)
      super(message)
      @code = code
      @error_details = error_details
      @request_body = request_body
    end
  end

  # Superclass & fallback for all 4XX errors
  class HTTPClientError < HTTPErrorResponse; end
  class HTTPIntermittentClientError < HTTPClientError; end

  class HTTPNotFound < HTTPClientError; end
  class HTTPGone < HTTPClientError; end
  class HTTPPayloadTooLarge < HTTPClientError; end
  class HTTPUnauthorized < HTTPClientError; end
  class HTTPForbidden < HTTPClientError; end
  class HTTPConflict < HTTPClientError; end
  class HTTPUnprocessableEntity < HTTPClientError; end
  class HTTPTooManyRequests < HTTPIntermittentClientError; end

  # Superclass & fallback for all 5XX errors
  class HTTPServerError < HTTPErrorResponse; end
  class HTTPIntermittentServerError < HTTPServerError; end

  class HTTPInternalServerError < HTTPServerError; end
  class HTTPBadGateway < HTTPIntermittentServerError; end
  class HTTPUnavailable < HTTPIntermittentServerError; end
  class HTTPGatewayTimeout < HTTPIntermittentServerError; end

  module ExceptionHandling
    def build_specific_http_error(response)
      url = response.env.url.to_s
      error_code = response.status
      error_details = response.reason_phrase
      response_body = response.body
      request_body = nil
      message = "URL: #{url}\nResponse body:\n#{response_body}\n\nRequest body:\n#{request_body}"
      error_class_for_code(error_code).new(error_code, message, error_details)
    end

    def error_class_for_code(code)
      case code
      when 401
        GovukApi::HTTPUnauthorized
      when 403
        GovukApi::HTTPForbidden
      when 404
        GovukApi::HTTPNotFound
      when 409
        GovukApi::HTTPConflict
      when 410
        GovukApi::HTTPGone
      when 413
        GovukApi::HTTPPayloadTooLarge
      when 422
        GovukApi::HTTPUnprocessableEntity
      when 429
        GovukApi::HTTPTooManyRequests
      when (400..499)
        GovukApi::HTTPClientError
      when 500
        GovukApi::HTTPInternalServerError
      when 502
        GovukApi::HTTPBadGateway
      when 503
        GovukApi::HTTPUnavailable
      when 504
        GovukApi::HTTPGatewayTimeout
      when (500..599)
        GovukApi::HTTPServerError
      else
        GovukApi::HTTPErrorResponse
      end
    end
  end
end
