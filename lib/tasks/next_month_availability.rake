namespace :room do
  desc "Tạo availability cho toàn bộ phòng trong tháng sau"
  task create_next_month_availability: :environment do
    start_date = (Time.zone.today.beginning_of_month + 3.months)
    end_date   = start_date.end_of_month

    puts "👉 Đang tạo availability từ #{start_date} đến #{end_date}..."

    Room.find_each do |room|
      (start_date..end_date).each do |available_date|
        RoomAvailability.find_or_create_by!(room:, available_date:) do |ra|
          ra.price = room.room_type.price
          ra.is_available = true
        end
      end
    end

    puts "🎉 Hoàn tất tạo availability cho tháng sau!"
  end
end
