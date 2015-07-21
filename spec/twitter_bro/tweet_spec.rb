require "spec_helper"

RSpec.describe TwitterBro::Tweet do
  let(:text) { "text" }

  let(:tweet) do
    described_class.new text: text
  end

  subject { tweet }

  its(:text) { is_expected.to eq text }
end
