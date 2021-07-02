module Productive
  class Booking
    def to_support_rotation
      SupportRotaToProductive::SupportRotation.new(
        employee: employee,
        date: started_on.to_date,
        productive_booking: self
      )
    end

    private

    def employee
      SupportRotaToProductive::Employee.new(email: person.email.downcase)
    end
  end
end
