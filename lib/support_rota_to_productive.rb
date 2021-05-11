require "dotenv"
Dotenv.load

require "active_support/all"
require "productive"

Productive.configure do |config|
  config.api_key = ENV.fetch("PRODUCTIVE_API_KEY")
  config.account_id = ENV.fetch("PRODUCTIVE_ACCOUNT_ID")
end

require "support_rota_to_productive/employee"
require "support_rota_to_productive/send_to_productive"
require "support_rota_to_productive/import"
require "support_rota_to_productive/support_rotation"
require "support_rota_to_productive/support_rota_client"
module SupportRotaToProductive
end
