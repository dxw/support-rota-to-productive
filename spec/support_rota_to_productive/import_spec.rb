require "spec_helper"

RSpec.describe SupportRotaToProductive::Import do
  before(:each) do
    stub_productive_service(SupportRotaToProductive::SUPPORT_SERVICE_ID)
    stub_employee_as_on_support
    allow(SupportRotaToProductive::LOGGER).to receive(:info)
    Timecop.freeze(Date.new(2021, 3, 1))
  end

  describe "#run" do
    it "creates missing bookings" do
      person = create_and_stub_person(email: "joe@dxw.com")

      # Get Support Rota events
      stub_support_rota_service(type: :dev, fixture_file_name: "one-event")
      stub_support_rota_service(type: :ops, fixture_file_name: "one-event")

      # Get Productive bookings
      stub_productive_get_bookings(bookings: [])

      create_request = stub_booking_create

      described_class.new.run

      expect(create_request).to have_been_requested.twice

      expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("Creating support shift for #{person.email} on 2021-03-01").twice
      expect(SupportRotaToProductive::LOGGER)
        .to have_received(:info).with("2 item(s) added, 0 item(s) deleted")
    end

    it "deletes a booking that no longer exists in the rota" do
      person = create_and_stub_person(email: "joe@dxw.com")

      # Get Support Rota events
      stub_support_rota_service(type: :dev, fixture_file_name: "no-events")
      stub_support_rota_service(type: :ops, fixture_file_name: "no-events")

      # Get Productive bookings
      booking_that_no_longer_exists_in_the_rota = create(:booking, person: person)
      stub_productive_get_bookings(bookings: [booking_that_no_longer_exists_in_the_rota])

      delete = stub_booking_delete(booking_that_no_longer_exists_in_the_rota.id)

      described_class.new.run

      expect(delete).to have_been_requested
      expect(SupportRotaToProductive::LOGGER)
        .to have_received(:info).with("Deleting support shift for #{person.email} on #{booking_that_no_longer_exists_in_the_rota.started_on}")
      expect(SupportRotaToProductive::LOGGER)
        .to have_received(:info).with("0 item(s) added, 1 item(s) deleted")
    end

    context "when the support rota includes historic data (more than 1 day ago)" do
      it "does not create a Productive booking" do
        _person = create_and_stub_person(email: "tom@dxw.com")

        # Get Support Rota events
        stub_support_rota_service(type: :dev, fixture_file_name: "one-historic-event")
        stub_support_rota_service(type: :ops, fixture_file_name: "no-events")

        # Get Productive bookings
        stub_productive_get_bookings(bookings: [])

        create_request = stub_booking_create

        described_class.new.run

        expect(create_request).not_to have_been_requested.twice
      end
    end

    context "when dry run is true" do
      it "does not create a missing booking" do
        # Get Support Rota events
        stub_support_rota_service(type: :dev, fixture_file_name: "no-events")
        stub_support_rota_service(type: :ops, fixture_file_name: "no-events")

        # Get Productive bookings
        stub_productive_get_bookings(bookings: [])

        create_request = stub_booking_create

        described_class.new(dry_run: true).run

        expect(create_request).to_not have_been_requested
      end

      it "does not delete a booking" do
        # Get Support Rota events
        stub_support_rota_service(type: :dev, fixture_file_name: "no-events")
        stub_support_rota_service(type: :ops, fixture_file_name: "no-events")

        # Get Productive bookings
        booking = create(:booking)
        stub_productive_get_bookings(bookings: [booking])

        delete_request = stub_booking_delete(booking.id)

        described_class.new(dry_run: true).run

        expect(delete_request).to_not have_been_requested
      end

      it "adds log entries" do
        person = create_and_stub_person(email: "joe@dxw.com")

        # Get Support Rota events
        stub_support_rota_service(type: :dev, fixture_file_name: "one-event")
        stub_support_rota_service(type: :ops, fixture_file_name: "no-events")

        # Get Productive bookings
        booking_that_no_longer_exists_in_the_rota = create(:booking, person: person, started_on: Date.yesterday)
        stub_productive_get_bookings(bookings: [booking_that_no_longer_exists_in_the_rota])

        described_class.new(dry_run: true).run

        expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("Creating support shift for #{person.email} on 2021-03-01")
        expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("Deleting support shift for #{person.email} on #{booking_that_no_longer_exists_in_the_rota.started_on}")
      end
    end
  end

  def create_and_stub_person(email:)
    employee = FactoryBot.create(:employee, email: email)
    person = create(:person, email: employee.email)
    stub_project_assignment_for_employee_and_project(
      employee.productive_id, SupportRotaToProductive::SUPPORT_PROJECT_ID
    )

    person
  end

  def stub_employee_as_on_support
    allow_any_instance_of(SupportRotaToProductive::SendToProductive)
      .to receive(:employee_assigned_to_support_project?)
      .and_return(true)
  end
end
