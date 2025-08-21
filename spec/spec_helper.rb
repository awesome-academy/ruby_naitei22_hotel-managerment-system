require "simplecov"
require "simplecov-rcov"
require "factory_bot_rails"

class SimpleCov::Formatter::MergedFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end

SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

SimpleCov.start "rails" do
  add_filter do | source_file|
    !source_file.filename.include?("app/models/room_type.rb")
  end

  add_group "Models", "app/models"

  minimum_coverage 100
  minimum_coverage_by_file 100

  formatter SimpleCov:: Formatter:: HTMLFormatter

  refuse_coverage_drop
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.include FactoryBot::Syntax::Methods
end
