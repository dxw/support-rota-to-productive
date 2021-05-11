module SupportRotaToProductive
  class Import
    def initialize(dry_run: false)
      @dry_run = dry_run
    end

    def run
      delete_all_future_bookings
      create_bookings_from_support_rotations
    end

    private

    def delete_all_future_bookings
      SendToProductive.delete_all_future_bookings(@dry_run)
    end

    def create_bookings_from_support_rotations
      SupportRotation.from_support_rota.each do |rotation|
        booking = SupportRotaToProductive::SendToProductive.new(rotation, @dry_run)
        booking.save
      end
    end
  end
end
