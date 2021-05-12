module SupportRotaToProductive
  class SupportRotation
    include ActiveModel::Model
    attr_accessor :date, :employee

    class << self
      def all
        developers = JSON.parse(client.get(developer_endpoint))
        ops = JSON.parse(client.get(ops_endpoint))

        result = developers + ops

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
