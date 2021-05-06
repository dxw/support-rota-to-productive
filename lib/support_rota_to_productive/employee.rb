module SupportRotaToProductive
  class Employee
    include ActiveModel::Model
    attr_accessor :email

    def to_productive
      @to_productive ||= self.class.all_productive_employees.find { |e| e.email == email }
    end

    def productive_id
      to_productive.attributes["id"]
    end

    class << self
      def all_productive_employees
        @all_productive_employees ||= Productive::Person.all
      end
    end
  end
end
