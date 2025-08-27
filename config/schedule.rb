set :output, "log/cron.log"
set :environment, "development"

every 1.day, at: "9:00 am" do
  rake "reservations:send_checkin_reminders"
end
