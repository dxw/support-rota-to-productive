require "spec_helper"

RSpec.describe SupportRotaToProductive::SendToProductive do
  let(:dry_run) { false }

  before do
    allow(SupportRotaToProductive::LOGGER).to receive(:info)
    allow_any_instance_of(described_class)
      .to receive(:employee_assigned_to_support_project?).and_return(true)
  end

  describe "#save" do
    let!(:service_request) { stub_productive_service(SupportRotaToProductive::SUPPORT_SERVICE_ID) }

    context "when a person exists in Productive" do
      let(:employee) { create(:employee, email: "foo@example.com") }
      let(:person) { create(:person, email: employee.email) }
      let(:support_rotation) { create(:support_rotation, employee: employee) }
      let!(:booking_request) { stub_booking_create }

      before(:each) do
        stub_people(people: [person])
      end

      it "creates a booking in productive" do
        described_class.new(support_rotation, dry_run).save

        expect(booking_request).to have_been_requested
      end

      it "logs the creation of a booking" do
        described_class.new(support_rotation, dry_run).save

        expect(SupportRotaToProductive::LOGGER)
          .to have_received(:info)
          .with("Creating support shift for #{employee.email} on #{support_rotation.date}")
      end

      context "but they are not assigned to the support project" do
        let!(:project_assignment_request) { stub_project_assignment_create }

        it "assigns the employee to the support project" do
          subject = described_class.new(support_rotation, dry_run)
          allow(subject).to receive(:employee_assigned_to_support_project?).and_return(false)

          subject.save

          expect(project_assignment_request).to have_been_requested
        end
      end

      context "when `dry_run` is true" do
        let(:dry_run) { true }

        it "does not create a booking in productive" do
          described_class.new(support_rotation, dry_run).save

          expect(booking_request).to_not have_been_requested
        end

        it "logs the creation of a booking" do
          described_class.new(support_rotation, dry_run).save

          expect(SupportRotaToProductive::LOGGER)
            .to have_received(:info)
            .with("Creating support shift for #{employee.email} on #{support_rotation.date}")
        end
      end
    end

    context "when a person does not exist in Productive" do
      let(:support_rotation) { create(:support_rotation, employee: employee_not_in_productive) }
      let(:employee_not_in_productive) { create(:employee, :not_in_productive) }
      let!(:booking_request) { a_request(:post, "https://api.productive.io/api/v2/bookings") }

      before(:each) { stub_people(people: []) }

      it "shows a log message" do
        described_class.new(support_rotation, dry_run).save

        expect(SupportRotaToProductive::LOGGER)
          .to have_received(:info)
          .with("Cannot find an entry in Productive for #{employee_not_in_productive.email}")
      end

      it "does not create a booking in productive" do
        described_class.new(support_rotation, dry_run).save

        expect(booking_request).to_not have_been_requested
      end

      context "when `dry_run` is true" do
        let(:dry_run) { true }

        it "does not create a booking in productive" do
          described_class.new(support_rotation, dry_run).save

          expect(booking_request).to_not have_been_requested
        end

        it "logs the creation of a booking" do
          described_class.new(support_rotation, dry_run).save

          expect(SupportRotaToProductive::LOGGER)
            .to have_received(:info)
            .with("Cannot find an entry in Productive for #{employee_not_in_productive.email}")
        end
      end
    end
  end
end
