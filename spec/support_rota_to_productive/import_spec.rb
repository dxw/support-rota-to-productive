require "spec_helper"

RSpec.describe SupportRotaToProductive::Import do
  let(:dry_run) { false }
  subject { described_class.new(dry_run: dry_run) }

  let!(:service_request) { stub_productive_service(SupportRotaToProductive::Booking::SUPPORT_SERVICE_ID) }
  let!(:support_rota_request) { stub_support_rota_service }
  let!(:employee) { FactoryBot.create(:employee, email: 'joe@dxw.com') }

  before do
    allow(SupportRotaToProductive::Booking::LOGGER).to receive(:info)
  end

  describe "#run" do
    let(:existing_bookings) { create_list(:booking, 7) }
    let(:support_rotations) { create_list(:support_rotation, 5) }

    let!(:booking_creation_stub) { stub_booking_create }

    let!(:booking_deletion_stubs) do
      existing_bookings.map do |booking|
        stub_booking_delete(booking.id)
      end
    end

    before do
      subject.run
    end

    it "creates a booking for the support rotation" do
      expect(booking_creation_stub).to have_been_requested
    end

    it "logs the creation of the booking" do
      expect(SupportRotaToProductive::Booking::LOGGER).to have_received(:info).with(
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
        expect(SupportRotaToProductive::Booking::LOGGER).to have_received(:info).with(
          "Deleting support shift for #{booking.person.email} on #{booking.started_on}"
        )
      end
    end

    context "when dry run is true" do
      let(:dry_run) { true }

      it "does not create bookings for every support rotation" do
        expect(booking_creation_stub).to_not have_been_requested
      end

      it "logs the creation of the booking" do
        expect(SupportRotaToProductive::Booking::LOGGER).to have_received(:info).with(
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
          expect(SupportRotaToProductive::Booking::LOGGER).to have_received(:info).with(
            "Deleting support shift for #{booking.person.email} on #{booking.started_on}"
          )
        end
      end
    end
  end
end
