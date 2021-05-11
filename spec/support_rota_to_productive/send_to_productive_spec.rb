require "spec_helper"

RSpec.describe SupportRotaToProductive::SendToProductive do
  let(:employee) { create(:employee, email: "foo@example.com") }
  let(:support_rotation) { create(:support_rotation, employee: employee) }
  let(:dry_run) { false }
  let!(:people_request) { stub_people }

  subject { described_class.new(support_rotation, dry_run) }

  before do
    allow(SupportRotaToProductive::LOGGER).to receive(:info)
  end

  describe "#save" do
    before do
      allow(subject).to receive(:employee_assigned_to_support_project?).and_return(true)
    end

    let!(:service_request) { stub_productive_service(SupportRotaToProductive::SUPPORT_SERVICE_ID) }

    context "when a person exists in Productive" do
      let!(:project_assignment_request) {
        stub_project_assignment_for_employee_and_project(employee.productive_id, SupportRotaToProductive::SUPPORT_PROJECT_ID)
      }
      let!(:booking_request) { stub_booking_create }

      it "creates a booking in productive" do
        subject.save

        expect(booking_request).to have_been_requested
      end

      it "logs the creation of a booking" do
        subject.save

        expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("Creating support shift for #{employee.email} on #{support_rotation.date}")
      end

      context "but they are not assigned to the support project" do
        let!(:project_assignment_request) { stub_project_assignment_create }

        it "assigns the employee to the support project" do
          allow(subject).to receive(:employee_assigned_to_support_project?).and_return(false)

          subject.save

          expect(project_assignment_request).to have_been_requested
        end
      end

      context "when `dry_run` is true" do
        let(:dry_run) { true }

        it "does not create a booking in productive" do
          subject.save

          expect(booking_request).to_not have_been_requested
        end

        it "logs the creation of a booking" do
          subject.save

          expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("Creating support shift for #{employee.email} on #{support_rotation.date}")
        end
      end
    end

    context "when a person does not exist in Productive" do
      let!(:employees) { create_list(:employee, 5) }
      let(:employee) { create(:employee, :not_in_productive) }

      let!(:booking_request) { a_request(:post, "https://api.productive.io/api/v2/bookings") }

      it "shows a log message" do
        subject.save

        expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("Cannot find an entry in Productive for #{employee.email}")
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

          expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("Cannot find an entry in Productive for #{employee.email}")
        end
      end
    end
  end
end
