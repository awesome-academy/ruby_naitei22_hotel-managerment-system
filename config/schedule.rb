set :output, "log/cron.log"
set :environment, "development"

every 1.day, at: "10:00 pm" do
  rake "bookings:complete_booking"
end
