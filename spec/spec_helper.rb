$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")

require "support_rota_to_productive"

require "webmock/rspec"
require "timecop"
require "ffaker"
require "pry"
require "climate_control"

require "support/service_stubs"
require "support/factory_bot"
require "support/rake_helpers"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:each) do
    FactoryBot.reload
    SupportRotaToProductive::Employee.instance_variable_set(:@all_productive_employees, nil)
  end

  config.around do |example|
    ClimateControl.modify(
      IMPORT_DEV_IN_HOURS: "true",
      IMPORT_OPS_IN_HOURS: "true",
      SUPPORT_ROTA_API_URI: "https://dxw-support-rota.herokuapp.com"
    ) { example.run }
  end
end
