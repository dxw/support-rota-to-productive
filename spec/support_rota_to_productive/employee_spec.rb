require "spec_helper"

RSpec.describe SupportRotaToProductive::Employee do
  describe ".new" do
    it "should return an Employee object" do
      result = described_class.new
      expect(result).to be_a(SupportRotaToProductive::Employee)
    end
  end

  describe "#to_productive" do
    it "returns a Productive person object" do
      productive_employee = build(:employee, email: "foo@example.com")
      support_rota_person = create(:person, email: "foo@example.com")
      stub_people(people: [support_rota_person])

      result = productive_employee.to_productive

      expect(result).to be_a(Productive::Person)
      expect(result.email).to eq("foo@example.com")
    end
  end
end
