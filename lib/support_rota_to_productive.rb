require "dotenv"
Dotenv.load

require "active_support/all"
require "productive"

Productive.configure do |config|
  config.api_key = ENV.fetch("PRODUCTIVE_API_KEY")
  config.account_id = ENV.fetch("PRODUCTIVE_ACCOUNT_ID")
end

require "support_rota_to_productive/employee"
require "support_rota_to_productive/booking"
require "support_rota_to_productive/import"
module SupportRotaToProductive
end
