class SupportRotaClient
  def initialize
    @api_base = ENV["SUPPORT_ROTA_API_URI"]
  end

  attr_reader :api_base

  def connection
    Faraday.new(url: api_base) do |faraday|
      faraday.request :retry, max: 5, interval: 0.5, exceptions: [Faraday::ConnectionFailed, Errno::ETIMEDOUT, Timeout::Error]
      faraday.adapter Faraday.default_adapter
    end
  end

  def get(endpoint)
    connection.get(endpoint).body
  end
end
