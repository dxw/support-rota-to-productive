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

  describe "#eql?" do
    let(:support_rotation_1) { create(:support_rotation, employee: employee, date: Date.today) }
    let(:support_rotation_2) { create(:support_rotation, employee: employee, date: Date.today) }
    let(:support_rotation_3) { create(:support_rotation) }

    it "returns true if the objects have the same attributes" do
      expect(support_rotation_1).to eq(support_rotation_2)
    end

    it "returns false if the objects don't have the same attributes" do
      expect(support_rotation_1).to_not eq(support_rotation_3)
    end

    context "with arrays" do
      let(:extra_item) { create(:support_rotation) }

      let(:support_rotation_list_1) do
        [
          create(:support_rotation, date: Date.parse("2021-01-01"), employee: employee),
          create(:support_rotation, date: Date.parse("2021-02-01"), employee: employee),
          create(:support_rotation, date: Date.parse("2021-03-01"), employee: employee)
        ]
      end
      let(:support_rotation_list_2) do
        [
          *support_rotation_list_1,
          extra_item
        ]
      end

      it "matches two arrays of objects" do
        expect(support_rotation_list_2 - support_rotation_list_1).to eq([extra_item])
      end
    end
  end
end
