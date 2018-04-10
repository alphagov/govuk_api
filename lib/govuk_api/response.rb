require "json"

module GovukApi
  class Response
    attr_reader :body, :headers, :url

    def initialize(faraday_response)
      @body = faraday_response.body
      @headers = faraday_response.headers
      @url = faraday_response.env.url.to_s
    end

    def to_hash
      JSON.parse(body)
    end
  end
end
