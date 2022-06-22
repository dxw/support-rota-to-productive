module SupportRotaToProductive
  class SupportRotation
    include ActiveModel::Model
    attr_accessor :date, :employee, :productive_booking

    def eql?(other)
      employee.email == other.employee.email &&
        date == other.date
    end
    alias_method :==, :eql?

    def hash
      [date, employee.email].hash
    end

    class << self
      def from_support_rota
        result = []
        result << JSON.parse(client.get(developer_endpoint)) if ENV["IMPORT_DEV_IN_HOURS"].eql?("true")
        result << JSON.parse(client.get(ops_endpoint)) if ENV["IMPORT_OPS_IN_HOURS"].eql?("true")

        result.flatten.map do |support_day|
          next if Time.parse(support_day["date"]) < 1.day.ago
          new(values_for(support_day))
        end.compact
      end

      def from_productive
        Productive::Booking
          .where(project_id: SUPPORT_PROJECT_ID, after: Date.yesterday.iso8601)
          .all
          .map(&:to_support_rotation)
      end

      private

      def values_for(support_day)
        email = support_day.dig("person", "email")
        values = {}
        values[:date] = Date.parse(support_day.fetch("date", nil))
        values[:employee] = Employee.new(email: email)
        values
      end

      def developer_endpoint
        "/v2/dev/rota.json"
      end

      def ops_endpoint
        "/v2/ops/rota.json"
      end

      def client
        @client ||= SupportRotaClient.new
      end
    end
  end
end
