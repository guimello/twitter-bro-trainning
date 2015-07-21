require "spec_helper"

RSpec.describe TwitterBro::BearerToken do
  let(:value) { "text" }

  let(:token) do
    described_class.new value: value
  end

  subject { token }

  its(:value) { is_expected.to eq value }

  describe "#to_s" do
    subject { token.to_s }

    it { is_expected.to eq value }
  end
end
