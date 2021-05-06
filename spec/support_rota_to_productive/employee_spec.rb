require "spec_helper"

RSpec.describe SupportRotaToProductive::Employee do
  let(:employee) { create(:employee, email: "foo@example.com") }

  describe ".new" do
    subject { employee }

    it { should be_a(SupportRotaToProductive::Employee) }
  end

  describe "#to_productive" do
    subject { employee.to_productive }

    it "returns an employee's representation in productive" do
      expect(subject).to be_a(Productive::Person)

      expect(subject.email).to eq("foo@example.com")
    end
  end
end
