namespace :bookings do
  desc "Auto-complete bookings if all requests are checked out"
  task complete_booking: :environment do
    puts "Starting auto-completion of bookings after checkout..."

    confirmed_bookings = Booking.status_confirmed.includes(:requests)
    puts "Found #{confirmed_bookings.count} confirmed booking(s) to process"

    completed_count = 0
    confirmed_bookings.find_each do |booking|
      if booking.all_requests_checked_out?
        if booking.update(status: :completed)
          completed_count += 1
          puts "Booking ##{booking.id} (#{booking.booking_code}) completed"
        else
          puts "Booking ##{booking.id} not completed:
          #{booking.errors.full_messages.to_sentence}"
        end
      else
        pending_requests = booking.requests.where.not(status: :checked_out)
        puts "- Booking ##{booking.id} (#{booking.booking_code}) still has
        #{pending_requests.count} non-checked-out request(s)"
      end
    end
    puts "Task completed! #{completed_count}
    booking(s) were updated to completed."
  end
end
