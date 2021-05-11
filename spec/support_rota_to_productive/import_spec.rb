require "spec_helper"

RSpec.describe SupportRotaToProductive::Import do
  let(:dry_run) { false }
  subject { described_class.new(dry_run: dry_run) }

  let!(:service_request) { stub_productive_service(SupportRotaToProductive::SendToProductive::SUPPORT_SERVICE_ID) }
  let!(:support_rota_request_dev) { stub_support_rota_service("dev") }
  let!(:support_rota_request_ops) { stub_support_rota_service("ops") }
  let!(:dev_employee) { FactoryBot.create(:employee, email: "joe@dxw.com") }
  let!(:ops_employee) { FactoryBot.create(:employee, email: "petra@dxw.com") }

  before do
    allow(SupportRotaToProductive::SendToProductive::LOGGER).to receive(:info)
    allow_any_instance_of(SupportRotaToProductive::SendToProductive).to receive(:employee_assigned_to_support_project?).and_return(true)
  end

  describe "#run" do
    let(:existing_bookings) { create_list(:booking, 7) }

    let!(:booking_deletion_stubs) do
      existing_bookings.map do |booking|
        stub_booking_delete(booking.id)
      end
    end

    let!(:booking_creation_stubs) do
      [dev_employee, ops_employee].map do |employee|
        stub_booking_create(employee: employee)
      end
    end

    before do
      subject.run
    end

    it "creates a booking for the support rotation" do
      booking_creation_stubs.each do |stub|
        expect(stub).to have_been_requested
      end
    end

    it "logs the creation of the booking" do
      expect(SupportRotaToProductive::SendToProductive::LOGGER).to have_received(:info).with(
        "Creating support shift for joe@dxw.com on 2021-03-01"
      )
    end

    it "deletes existing bookings" do
      booking_deletion_stubs.each do |stub|
        expect(stub).to have_been_requested
      end
    end

    it "logs the deletion of each booking" do
      existing_bookings.each do |booking|
        expect(SupportRotaToProductive::SendToProductive::LOGGER).to have_received(:info).with(
          "Deleting support shift for #{booking.person.email} on #{booking.started_on}"
        )
      end
    end

    context "when dry run is true" do
      let(:dry_run) { true }

      it "does not create bookings for every support rotation" do
        booking_creation_stubs.each do |stub|
          expect(stub).to_not have_been_requested
        end
      end

      it "logs the creation of the booking" do
        expect(SupportRotaToProductive::SendToProductive::LOGGER).to have_received(:info).with(
          "Creating support shift for joe@dxw.com on 2021-03-01"
        )
      end

      it "does not delete existing bookings" do
        booking_deletion_stubs.each do |stub|
          expect(stub).to_not have_been_requested
        end
      end

      it "logs the deletion of each booking" do
        existing_bookings.each do |booking|
          expect(SupportRotaToProductive::SendToProductive::LOGGER).to have_received(:info).with(
            "Deleting support shift for #{booking.person.email} on #{booking.started_on}"
          )
        end
      end
    end
  end
end
