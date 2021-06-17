require "spec_helper"

RSpec.describe SupportRotaToProductive::SupportRotation do
  let(:employee) { SupportRotaToProductive::Employee.new(email: "foo@example.com") }

  after(:each) do
    SupportRotaToProductive::SupportRotation.instance_variable_set(:@from_support_rota, nil)
  end

  describe ".new" do
    let(:support_rotation) { described_class.new(employee: employee, date: Date.today) }
    subject { support_rotation }

    it { should be_a(SupportRotaToProductive::SupportRotation) }
  end

  describe ".from_support_rota" do
    it "returns support rotations" do
      stub_support_rota_service(type: :dev, fixture_file_name: "dev")
      stub_support_rota_service(type: :ops, fixture_file_name: "dev")

      created_support_rotations = create_list(:support_rotation, 4)

      result = described_class.from_support_rota

      expect(result.count).to eq(created_support_rotations.count)
      expect(result.first).to be_a(SupportRotaToProductive::SupportRotation)
    end
  end

  describe ".from_productive" do
    let(:support_rotations) { described_class.from_productive }

    it "returns bookings as support_rotations" do
      created_support_rotation = create(:booking)

      # Get Support Rota events
      stub_support_rota_service(type: :dev, fixture_file_name: "no-events")
      stub_support_rota_service(type: :ops, fixture_file_name: "no-events")

      # Get Productive bookings
      stub_productive_get_bookings(bookings: [created_support_rotation])

      expect(support_rotations.count).to eq(1)
      expect(support_rotations.first).to be_a(SupportRotaToProductive::SupportRotation)
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
