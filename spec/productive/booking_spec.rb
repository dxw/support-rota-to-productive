require "spec_helper"

RSpec.describe Productive::Booking do
  let(:employee) { create(:employee) }
  let(:booking) { create(:booking, employee: employee) }

  describe "#to_support_rotation" do
    subject { booking.to_support_rotation }

    it "converts the booking to a support rotation" do
      expect(subject).to be_a(SupportRotaToProductive::SupportRotation)
      expect(subject.date).to eq(booking.started_on.to_date)
      expect(subject.employee.email).to eq(booking.person.email)
      expect(subject.productive_booking).to eq(booking)
    end

    context "when the Productive employee has an email that is not all lower case" do
      it "lowercases it when creating SupportRotaToProductive::SupportRotation for reliable comparisons" do
        productive_person = create(:person, email: "foo@DXW.com")
        booking = create(:booking, person: productive_person)

        result = booking.to_support_rotation

        expect(result.employee.email).to eq("foo@dxw.com")
      end
    end
  end
end
