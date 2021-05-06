module SupportRotaToProductive
  class SupportRotation
    include ActiveModel::Model
    attr_accessor :date, :employee

    class << self
      def all
        json_endpoint = "/v2/dev/rota.json"

        result = JSON.parse(client.get(json_endpoint))

        result.map do |support_day|
          new(values_for(support_day))
        end
      end

      private

      def values_for(support_day)
        email = support_day.dig("person", "email")
        values = {}
        values[:date] = support_day.fetch("date")
        values[:employee] = Employee.new(email: email)
        values
      end

      def client
        @client ||= SupportRotaClient.new
      end
    end
  end
end
