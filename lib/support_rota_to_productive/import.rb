module SupportRotaToProductive
  class Import
    def initialize(dry_run: false)
      @dry_run = dry_run
    end

    def run
      added = support_rotations_to_add.map do |support_rotation|
        SendToProductive.new(support_rotation, @dry_run).save
      end.count { |item| item != false }

      deleted = support_rotations_to_delete.each do |support_rotation|
        LOGGER.info("Deleting support shift for #{support_rotation.employee.email} on #{support_rotation.date}")
        support_rotation.productive_booking.destroy unless @dry_run
      end.reduce(0) { |count| count + 1 }

      LOGGER.info("==========================================================")
      LOGGER.info("#{@dry_run ? "Dry run" : "Run"} complete!")
      LOGGER.info("#{added} item(s) added, #{deleted} item(s) deleted")
      LOGGER.info("==========================================================")
    end

    private

    def support_rotations_from_api
      @support_rotations_from_api ||= SupportRotation.from_support_rota
    end

    def support_rotations_from_productive
      @support_rotations_from_productive ||= SupportRotation.from_productive
    end

    def common_support_rotations
      support_rotations_from_api & support_rotations_from_productive
    end

    def support_rotations_to_add
      (support_rotations_from_api - common_support_rotations)
    end

    def support_rotations_to_delete
      (support_rotations_from_productive - common_support_rotations)
    end
  end
end
