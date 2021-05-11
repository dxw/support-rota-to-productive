require "spec_helper"

RSpec.describe SupportRotaToProductive::Import do
  let(:dry_run) { false }
  subject { described_class.new(dry_run: dry_run) }

  let!(:service_request) { stub_productive_service(SupportRotaToProductive::SUPPORT_SERVICE_ID) }
  let!(:support_rota_request_dev) { stub_support_rota_service("dev") }
  let!(:support_rota_request_ops) { stub_support_rota_service("ops") }
  let!(:dev_employee) { FactoryBot.create(:employee, email: "joe@dxw.com") }
  let!(:ops_employee) { FactoryBot.create(:employee, email: "petra@dxw.com") }

  before do
    stub_support_rota_service
    allow(SupportRotaToProductive::LOGGER).to receive(:info)
    allow_any_instance_of(SupportRotaToProductive::SendToProductive).to receive(:employee_assigned_to_support_project?).and_return(true)
  end

  describe "#run" do
    let(:employee) { create(:employee) }
    let(:extra_employee) { create(:employee) }
    let(:person) { create(:person, email: employee.email) }

    let(:booking_1) { create(:booking, person: person, started_on: Date.parse("2021-01-01"), ended_on: Date.parse("2021-01-10")) }
    let(:booking_2) { create(:booking, person: person, started_on: Date.parse("2021-02-01"), ended_on: Date.parse("2021-02-10")) }
    let(:booking_3) { create(:booking, person: person, started_on: Date.parse("2021-03-01"), ended_on: Date.parse("2021-03-10")) }
    let(:booking_4) { create(:booking, person: person, started_on: Date.parse("2021-04-01"), ended_on: Date.parse("2021-04-10")) }

    let(:extra_support_rotation) { create(:support_rotation, employee: extra_employee) }

    let!(:support_rotations_from_api) do
      [
        create(:support_rotation, date: booking_1.started_on, employee: employee),
        create(:support_rotation, date: booking_2.started_on, employee: employee),
        create(:support_rotation, date: booking_3.started_on, employee: employee),
        extra_support_rotation
      ]
    end

    let!(:create_stub) { stub_booking_create }
    let!(:delete_stub) { stub_booking_delete(booking_4.id) }

    before do
      allow(SupportRotaToProductive::SupportRotation).to receive(:from_support_rota).and_return(support_rotations_from_api)
    end

    it "creates the missing booking and deletes the extra booking" do
      described_class.new.run

      expect(create_stub).to have_been_requested
      expect(delete_stub).to have_been_requested
    end

    it "adds log entries" do
      described_class.new.run

      expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("Creating support shift for #{extra_support_rotation.employee.email} on #{extra_support_rotation.date}")
      expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("Deleting support shift for #{booking_4.person.email} on #{booking_4.started_on}")
      expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("1 item(s) added, 1 item(s) deleted")
    end

    context "when dry run is true" do
      it "does not create the missing booking and delete the extra booking" do
        described_class.new(dry_run: true).run

        expect(create_stub).to_not have_been_requested
        expect(delete_stub).to_not have_been_requested
      end

      it "adds log entries" do
        described_class.new(dry_run: true).run

        expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("Creating support shift for #{extra_support_rotation.employee.email} on #{extra_support_rotation.date}")
        expect(SupportRotaToProductive::LOGGER).to have_received(:info).with("Deleting support shift for #{booking_4.person.email} on #{booking_4.started_on}")
      end
    end
  end
end
