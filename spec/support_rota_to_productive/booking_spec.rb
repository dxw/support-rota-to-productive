require "spec_helper"

RSpec.describe SupportRotaToProductive::Booking do
  let(:employee) { create(:employee, email: "foo@example.com") }
  let(:support_rotation) { create(:support_rotation, employee: employee) }
  let(:dry_run) { false }

  subject { described_class.new(support_rotation, dry_run) }

  before do
    allow(described_class::LOGGER).to receive(:info)
  end

  describe "#save" do
    let!(:service_request) { stub_productive_service(SupportRotaToProductive::Booking::SUPPORT_SERVICE_ID) }

    context "when a person exists in Productive" do
      let!(:booking_request) { stub_booking_create }

      it "creates a booking in productive" do
        subject.save

        expect(booking_request).to have_been_requested
      end

      it "logs the creation of a booking" do
        subject.save

        expect(described_class::LOGGER).to have_received(:info).with("Creating support shift for #{employee.email} on #{support_rotation.date}")
      end

      context "when `dry_run` is true" do
        let(:dry_run) { true }

        it "does not create a booking in productive" do
          subject.save

          expect(booking_request).to_not have_been_requested
        end

        it "logs the creation of a booking" do
          subject.save

          expect(described_class::LOGGER).to have_received(:info).with("Creating support shift for #{employee.email} on #{support_rotation.date}")
        end
      end
    end

    context "when a person does not exist in Productive" do
      let!(:employees) { create_list(:employee, 5) }
      let(:employee) { create(:employee, :not_in_productive) }

      let!(:booking_request) { a_request(:post, "https://api.productive.io/api/v2/bookings") }

      it "shows a log message" do
        subject.save

        expect(described_class::LOGGER).to have_received(:info).with("Cannot find an entry in Productive for #{employee.email}")
      end

      it "does not create a booking in productive" do
        subject.save

        expect(booking_request).to_not have_been_requested
      end

      context "when `dry_run` is true" do
        let(:dry_run) { true }

        it "does not create a booking in productive" do
          subject.save

          expect(booking_request).to_not have_been_requested
        end

        it "logs the creation of a booking" do
          subject.save

          expect(described_class::LOGGER).to have_received(:info).with("Cannot find an entry in Productive for #{employee.email}")
        end
      end
    end
  end

  describe ".delete_all_future_bookings" do
    let!(:bookings) { create_list(:booking, 6) }
    let!(:delete_stubs) do
      bookings.map do |booking|
        stub_booking_delete(booking.id)
      end
    end

    it "deletes all future bookings" do
      described_class.delete_all_future_bookings(dry_run)

      delete_stubs.each do |stub|
        expect(stub).to have_been_requested
      end
    end
  end
end
