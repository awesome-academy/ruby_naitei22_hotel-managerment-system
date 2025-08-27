namespace :reservations do
  desc "Send check-in reminder emails for upcoming confirmed requests"

  task send_checkin_reminders: :environment do
    requests = Request.upcoming_confirmed

    requests.find_each do |request|
      RequestMailer.checkin_reminder(request).deliver_now
    end
  end
end
