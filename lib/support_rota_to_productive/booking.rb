module SupportRotaToProductive
  class Booking
    SUPPORT_SERVICE_ID = 882645

    LOGGER = Logger.new($stdout)

    attr_reader :employee, :start_date, :end_date, :dry_run, :productive_person

    def initialize(support_rotation, dry_run)
      @employee = support_rotation.employee
      @productive_person = support_rotation.employee.to_productive
      @start_date = support_rotation.date.to_date
      @end_date = support_rotation.date.to_date
      @dry_run = dry_run
    end

    def save
      if productive_person.nil?
        LOGGER.info("Cannot find an entry in Productive for #{employee.email}")
      else
        create_booking
      end
    end

    class << self
      def delete_all_future_bookings(dry_run)
        future_bookings = Productive::Booking.where(event_id: SUPPORT_SERVICE_ID, after: Date.today).all

        future_bookings.each do |booking|
          LOGGER.info("Deleting support shift for #{booking.person.email} from #{booking.started_on} - #{booking.ended_on}")
          booking.destroy unless dry_run
        end
      end
    end

    private

    def create_booking(start_date: @start_date, end_date: @end_date, time: 420)
      LOGGER.info("Creating support shift for #{employee.email} from #{start_date} - #{end_date}")

      unless dry_run
        booking = Productive::Booking.new
        booking.relationships["person"] = productive_person
        booking.relationships["service"] = self.class.support_service
        booking.started_on = start_date.to_date
        booking.ended_on = end_date.to_date
        booking.approved = true
        booking.time = time
        booking.save
      end
    end

    class << self
      def support_service
        @support_service ||= Productive::Service.find(SUPPORT_SERVICE_ID).first
      end
    end
  end
end
