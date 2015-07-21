require "base64"
require "faraday"
require "json"

module TwitterBro
  class Client

    attr_accessor :consumer_key
    attr_accessor :consumer_secret_key

    class Error < StandardError; end
    class RequestError < Error
      attr_reader :response

      def initialize(message = nil, response = nil)
        super(message)

        @response = response
      end
    end

    class Forbidden < RequestError; end

    def initialize(consumer_key:, consumer_secret_key:)
      @consumer_key = consumer_key
      @consumer_secret_key = consumer_secret_key
    end

    def base_api_path
      ENV.fetch "TWITTER_BASE_API"
    end

    def http_client(&block)
      Faraday.new(url: base_api_path, &block)
    end

    def bearer_token
      return @bearer_token if @bearer_token

      response = http_client.post do |req|
        req.url "/oauth2/token"

        req.body = "grant_type=client_credentials"

        req.headers["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
        req.headers["Authorization"] = "Basic #{encoded_bearer_credential}"
      end

      validate_response! response

      @bearer_token = TwitterBro::BearerToken.new value: JSON.parse(response.body)["access_token"]
    end

    def search(text)
      response = http_client.get do |req|
        req.url "/1.1/search/tweets.json"

        req.headers["Authorization"] = "Bearer #{bearer_token}"

        req.params["q"] = text
      end

      validate_response! response

      JSON.parse(response.body)["statuses"].map do |status|
        TwitterBro::Tweet.new text: status["text"]
      end
    end

    def encoded_bearer_credential
      Base64.strict_encode64 "#{consumer_key}:#{consumer_secret_key}"
    end

    private

    def validate_response!(response)
      return if response.success?

      case response.status
      when 403 then fail Forbidden.new("lol forbidden", response)
      else fail RequestError.new("unknown error: #{response.status}", response)
      end
    end
  end
end
