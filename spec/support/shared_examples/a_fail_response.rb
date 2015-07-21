RSpec.shared_examples "a fail response" do
  context "when the request fails" do
    context "when forbidden" do
      let(:rack_response) { [403, {}, ""] }

      it do
        aggregate_failures "requesting" do
          expect { subject }.to raise_error do |error|
            expect(error).to be_a TwitterBro::Client::Forbidden
            expect(error.response).to be_a Faraday::Response
          end
        end
      end
    end

    context "when any unmapped error" do
      let(:rack_response) { [500, {}, ""] }

      it do
        aggregate_failures "requesting" do
          expect { subject }.to raise_error do |error|
            expect(error).to be_a TwitterBro::Client::RequestError
            expect(error.response).to be_a Faraday::Response
          end
        end
      end
    end
  end
end
