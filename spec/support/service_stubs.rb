module ServiceStubs
  def stub_support_rota_service
    body = JSON.parse(File.read(File.join("spec", "fixtures", "support_rota", "result.json"))).to_json
    stub_request(:get, "https://dxw-support-rota.herokuapp.com/v2/dev/rota.json")
      .to_return(status: 200, body: body, headers: {})
  end

  def stub_productive_service(id)
    url = "https://api.productive.io/api/v2/services/#{id}"
    body = JSON.parse(File.read(File.join("spec", "fixtures", "productive", "event.json"))).to_json
    stub_request(:get, url)
      .to_return(
        status: 200,
        body: body,
        headers: {
          "Content-Type" => "application/json"
        }
      )
  end

  def stub_booking_create
    stub_request(:post, "https://api.productive.io/api/v2/bookings")
      .to_return(status: 200, body: "", headers: {})
  end

  def stub_booking_delete(id)
    stub_request(:delete, "https://api.productive.io/api/v2/bookings/#{id}")
      .to_return(status: 204, body: "", headers: {})
  end
end

RSpec.configure do |config|
  config.include ServiceStubs
end
