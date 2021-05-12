module ServiceStubs
  def stub_support_rota_service(type = "dev")
    body = JSON.parse(File.read(File.join("spec", "fixtures", "support_rota", "#{type}.json"))).to_json
    stub_request(:get, "https://dxw-support-rota.herokuapp.com/v2/#{type}/rota.json")
      .to_return(status: 200, body: body, headers: {})
  end

  def stub_productive_service(id)
    stub_request(:get, "https://api.productive.io/api/v2/services/#{id}")
      .to_return(status: 200, body: "", headers: {})
  end

  def stub_booking_create(employee:)
    stub_request(:post, "https://api.productive.io/api/v2/bookings")
      .with(
        body: {
          "data" => {
            "type" => "bookings",
            "relationships" => {
              "person" => {
                "data" => {
                  "type" => "people",
                  "id" => employee.productive_id
                }
              },
              "service" => {
                "data" => nil
              }
            },
            "attributes" => {
              "started_on" => "2021-03-01",
              "ended_on" => "2021-03-01",
              "approved" => true,
              "time" => 420
            }
          }
        }.to_json
      ).to_return(status: 200, body: "", headers: {})
  end

  def stub_booking_delete(id)
    stub_request(:delete, "https://api.productive.io/api/v2/bookings/#{id}")
      .to_return(status: 204, body: "", headers: {})
  end

  def stub_project_assignment_create
    stub_request(:post, "https://api.productive.io/api/v2/project_assignments")
      .to_return(status: 200, body: "", headers: {})
  end

  def stub_project_assignment_for_employee_and_project(person_id, project_id)
    stub_request(:get, "https://api.productive.io/api/v2/project_assignments?filter[person_id]=#{person_id}&filter[project_id]=#{project_id}")
      .to_return(status: 200, body: "", headers: {})
  end

  def stub_person_with_id(person_id)
    stub_request(:get, "https://api.productive.io/api/v2/people/#{person_id}")
      .to_return(status: 200, body: "", headers: {})
  end

  def stub_people
    stub_request(:get, "https://api.productive.io/api/v2/people")
      .to_return(status: 200, body: "", headers: {})
  end
end

RSpec.configure do |config|
  config.include ServiceStubs
end
