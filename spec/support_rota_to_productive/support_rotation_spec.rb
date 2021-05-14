require "spec_helper"

RSpec.describe SupportRotaToProductive::SupportRotation do
  let(:employee) { SupportRotaToProductive::Employee.new(email: "foo@example.com") }
  let(:support_rotation) { described_class.new(employee: employee, date: Date.today) }
  let!(:support_rota_request_dev) { stub_support_rota_service("dev") }
  let!(:support_rota_request_ops) { stub_support_rota_service("ops") }

  describe ".new" do
    subject { support_rotation }
    it { should be_a(SupportRotaToProductive::SupportRotation) }
  end

  describe ".all" do
    it "returns all developer & ops support shifts as SupportRotation objects" do
      expect(SupportRotaToProductive::SupportRotation.all).to be_an(Array)
      expect(SupportRotaToProductive::SupportRotation.all.count).to eq(4)
      expect(SupportRotaToProductive::SupportRotation.all.first).to be_a(SupportRotaToProductive::SupportRotation)
    end
  end
end
