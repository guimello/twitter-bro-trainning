require "spec_helper"

RSpec.describe TwitterBro::Client do
  let(:consumer_key) { "le consumer key" }
  let(:consumer_secret_key) { "le consumer secret key" }

  let(:client) do
    described_class.new consumer_key: consumer_key, consumer_secret_key: consumer_secret_key
  end

  subject { client }

  its(:consumer_key) { is_expected.to eq consumer_key }
  its(:consumer_secret_key) { is_expected.to eq consumer_secret_key }

  describe "#search" do
    let(:text) { "word" }

    let(:tweet) { TwitterBro::Tweet.new text: "le body" }
    let(:bearer_token) { TwitterBro::BearerToken.new value: "le token" }

    let(:rack_response) { [ 200, {}, { "statuses" => [tweet.as_json] }.to_json ] }

    let(:request_headers) do
      {
        "Authorization" => "Bearer #{bearer_token}"
      }
    end

    let(:http_stub) do
      Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get("/1.1/search/tweets.json?q=#{text}", request_headers) do |env|
            rack_response
          end
        end
      end
    end

    before do
      allow(client).to receive(:bearer_token).and_return bearer_token
      allow(client).to receive(:http_client).and_return http_stub
    end

    subject(:search) { client.search text }

    it do
      is_expected.to have(1).tweet
    end

    describe "tweet" do
      subject { search.first }

      it do
        is_expected.to eq tweet
      end
    end

    it_behaves_like "a fail response"
  end

  describe "#bearer_token" do
    let(:base_api_path) { "http://google.com" }
    let(:bearer_token) { TwitterBro::BearerToken.new value: "le token" }

    let(:response) do
      {
        "access_token" => bearer_token.value
      }
    end

    let(:encoded_key) { "encoded_key" }

    let(:request_body) { "grant_type=client_credentials" }
    let(:request_headers) do
      {
        "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8",
        "Authorization" => "Basic #{encoded_key}"
      }
    end

    let(:rack_response) { [ 200, {}, response.to_json ] }

    let(:http_stub) do
      Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.post("/oauth2/token", request_body, request_headers) do |env|
            rack_response
          end
        end
      end
    end

    before do
      allow(client).to receive(:base_api_path).and_return base_api_path
      allow(client).to receive(:http_client).and_return http_stub
      allow(client).to receive(:encoded_bearer_credential).and_return encoded_key
    end

    subject { client.bearer_token }

    it { is_expected.to eq bearer_token }

    it_behaves_like "a fail response"
  end

  describe "#base_api_path" do
    let!(:base_api_path) { ENV["TWITTER_BASE_API"] = "le api" }

    after do
      ENV.delete "TWITTER_BASE_API"
    end

    subject { client.base_api_path }

    it { is_expected.to eq base_api_path }
  end

  describe "#http_client" do
    let(:base_api_path) { "http://google.com" }

    before do
      allow(client).to receive(:base_api_path).and_return base_api_path
    end

    subject { client.http_client }

    it { is_expected.to be_a Faraday::Connection }

    context "with default attributes" do
      before do
        allow(Faraday).to receive(:new).and_return double
      end

      it do
        subject
        expect(Faraday).to have_received(:new).with url: base_api_path
      end
    end

    context "with a config block" do
      subject do
        client.http_client do |builder|
          builder.headers["lol"] =  "wut"
        end
      end

      its(:headers) { is_expected.to include "lol" => "wut" }
    end
  end

  describe "#encoded_bearer_credential" do
    let(:encoded_key) do
      Base64.strict_encode64 "#{consumer_key}:#{consumer_secret_key}"
    end

    subject { client.encoded_bearer_credential }

    it { is_expected.to eq encoded_key }
  end
end
