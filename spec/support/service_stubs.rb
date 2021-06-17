module ServiceStubs
  def stub_support_rota_service(type:, fixture_file_name:, date_of_earliest_support_event: nil)
    body_array = JSON.parse(File.read(File.join("spec", "fixtures", "support_rota", "#{fixture_file_name}.json")))

    body_array.first["date"] = date_of_earliest_support_event if date_of_earliest_support_event
    body = body_array.to_json

    stub_request(:get, "https://dxw-support-rota.herokuapp.com/v2/#{type}/rota.json")
      .to_return(status: 200, body: body, headers: {})
  end

  def stub_productive_service(id)
    stub_request(:get, "https://api.productive.io/api/v2/services/#{id}")
      .to_return(status: 200, body: "", headers: {})
  end

  def stub_booking_create
    stub_request(:post, "https://api.productive.io/api/v2/bookings")
      .to_return(status: 200, body: "", headers: {})
  end

  def stub_booking_delete(id)
    stub_request(:delete, "https://api.productive.io/api/v2/bookings/#{id}")
      .to_return(status: 204, body: "", headers: {})
  end

  def stub_productive_get_bookings(bookings: [], filter_date: Date.yesterday)
    url = "https://api.productive.io/api/v2/bookings?filter%5Bafter%5D=#{filter_date}&filter%5Bproject_id%5D=#{SupportRotaToProductive::SUPPORT_PROJECT_ID}"
    body = {"data" => [], "included" => []}

    unless bookings.empty?
      bookings.map do |booking|
        booking_data = booking.as_json
        booking_data[:relationships] = {
          person: {
            data: {
              type: "people", id: booking.person.id
            }
          }
        }

        body["data"] << booking_data
        body["included"] << booking.person.as_json
      end
    end

    stub_request(:get, url)
      .to_return(
        status: 200,
        body: body.to_json,
        headers: {
          "Content-Type" => "application/json"
        }
      )
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
