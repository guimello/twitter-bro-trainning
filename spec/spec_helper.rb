$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'twitter_bro'

require 'rspec/its'
require 'rspec/collection_matchers'
#require 'faraday'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.syntax = :expect
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.order = :random

  Kernel.srand config.seed
end
