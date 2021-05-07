module SupportRotaToProductive
  class Booking
    SUPPORT_SERVICE_ID = ENV.fetch("SUPPORT_SERVICE_ID")
    SUPPORT_PROJECT_ID = ENV.fetch("SUPPORT_PROJECT_ID")

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
      if @productive_person.nil?
        LOGGER.info("Cannot find an entry in Productive for #{employee.email}")
      else
        create_booking
      end
    end

    class << self
      def delete_all_future_bookings(dry_run)
        future_bookings = Productive::Booking.where(project_id: SUPPORT_PROJECT_ID, after: Date.today).all

        future_bookings.each do |booking|
          LOGGER.info("Deleting support shift for #{booking.person.email} on #{booking.started_on}")
          booking.destroy unless dry_run
        end
      end
    end

    private

    def employee_assigned_to_support_project?(employee)
      Productive::ProjectAssignment.find(person_id: employee.productive_id, project_id: SUPPORT_PROJECT_ID).any?
    end

    def create_booking(start_date: @start_date, end_date: @end_date, time: 420)
      unless dry_run
        unless employee_assigned_to_support_project?(employee)
          assignment = assign_employee_to_support_project(employee)
          if assignment.save
            LOGGER.info("#{employee.email} assigned to Support project id: #{SUPPORT_PROJECT_ID}" )
          end
        end

        productive_booking = Productive::Booking.new
        productive_booking.relationships["person"] = productive_person
        productive_booking.relationships["service"] = self.class.support_service
        productive_booking.started_on = start_date.to_date
        productive_booking.ended_on = end_date.to_date
        productive_booking.approved = true
        productive_booking.time = time
        productive_booking.save
      end

      LOGGER.info("Creating support shift for #{employee.email} on #{start_date}")
    end

    def assign_employee_to_support_project(employee)
      Productive::ProjectAssignment.new(project_id: SUPPORT_PROJECT_ID, person_id: employee.productive_id)
    end

    class << self
      def support_service
        @support_service ||= Productive::Service.find(SUPPORT_SERVICE_ID).first
      end
    end
  end
end
