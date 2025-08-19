namespace :cleanup do
  desc "Xóa RoomAvailability của tháng trước và các request đã checkout"
  task old_data: :environment do
    last_month_start = (Time.zone.today.beginning_of_month - 1.month)
    last_month_end   = last_month_start.end_of_month

    ra_to_delete = RoomAvailability
                   .where(available_date: last_month_start..last_month_end,
                          is_available: true)

    count_ra = ra_to_delete.count
    ra_to_delete.destroy_all
    puts "🗑️ Đã xóa #{count_ra} RoomAvailability của tháng trước"

    req_to_delete = Request.where(status: :checked_out)

    req_to_delete.find_each do |req|
      if req.check_in && req.check_out
        ra_related = RoomAvailability.where(
          room_id: req.room_id,
          available_date: req.check_in..req.check_out
        )
        ra_count = ra_related.count
        ra_related.destroy_all
        puts "🗑️ Đã xóa #{ra_count} RoomAvailability gắn với Request ##{req.id}"
      end
      req.destroy
    end

    puts "🎉 Cleanup hoàn tất!"
  end
end
