# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# db/seeds.rb
require "date"

puts "Deleting all tables..."

ActiveRecord::Base.connection.disable_referential_integrity do
  ActiveRecord::Base.connection.tables.each do |table|
    next if table == "schema_migrations" || table == "ar_internal_metadata"
    ActiveRecord::Base.connection.execute("DELETE FROM #{table};")
  end
end

puts "All tables cleared!"

User.create!(
  name: "Admin",
  email: "admin@gmail.com",
  password: "123456",
  phone: "729-551-3035",
  role: 1,
  confirmed_at: Time.zone.now # nếu bạn dùng confirmable
)

User.create!(
  name: "Aatrox",
  email: "a@gmail.com",
  password: "123456",
  phone: "523-468-9226x96295",
  role: 0,
  confirmed_at: Time.zone.now
)

User.create!(
  name: "Jared Snyder",
  email: "anthony41@lopez-fuller.com",
  password: "Password@123",
  phone: "306-359-9581x037",
  role: 0,
  confirmed_at: Time.zone.now
)

User.create!(
  name: "Crystal Cox",
  email: "jonesdouglas@gmail.com",
  password: "Password@123",
  phone: "+1-388-501-3262x5359",
  role: 1,
  confirmed_at: Time.zone.now
)

User.create!(
  name: "Alan Boyer",
  email: "douglasvaughn@yahoo.com",
  password: "Password@123",
  phone: "8809003047",
  role: 0,
  confirmed_at: Time.zone.now
)

RoomType.create!(
  name: "Single",
  description: "While speak also sort family without.",
  price: 51
)

RoomType.create!(
  name: "Double",
  description: "Oil know rise if.",
  price: 258
)

RoomType.create!(
  name: "Suite",
  description: "Truth of whole find he should.",
  price: 120
)

Room.create!(
  room_number: "R001",
  room_type_id: 3,
  description: "Serve itself national back.",
  capacity: 1,
  price_from_date: Date.today,
  price_to_date: Date.today + 60.days,
  price: 500
)

Room.create!(
  room_number: "R002",
  room_type_id: 2,
  description: "Evidence year threat anything. Why those talk relate.",
  capacity: 3,
  price_from_date: Date.today,
  price_to_date: Date.today + 60.days,
  price: 300
)

Room.create!(
  room_number: "R003",
  room_type_id: 3,
  description: "Less hot war music. Care officer only ready attorney which. They reduce customer follow card.",
  capacity: 4,
  price_from_date: Date.today,
  price_to_date: Date.today + 60.days,
  price: 400
)

Room.create!(
  room_number: "R004",
  room_type_id: 1,
  description: "State need can PM any. Light less tend capital training him.",
  capacity: 2,
  price_from_date: Date.today,
  price_to_date: Date.today + 60.days,
  price: 700
)

Room.create!(
  room_number: "R005",
  room_type_id: 2,
  description: "Leg result direction beyond. Near southern determine however point. Last thus then.",
  capacity: 3,
  price_from_date: Date.today,
  price_to_date: Date.today + 60.days,
  price: 800
)

Amenity.create!(
  name: "TV",
  description: "Never final hard benefit budget."
)

Amenity.create!(
  name: "Wi-Fi",
  description: "College should lot push able."
)

Amenity.create!(
  name: "AC",
  description: "Three safe late."
)

Amenity.create!(
  name: "Minibar",
  description: "Start term can high point present."
)

Amenity.create!(
  name: "Balcony",
  description: "Crime anyone civil home thought our."
)

RoomAmenity.create!(
  room_id: 1,
  amenity_id: 3
)

RoomAmenity.create!(
  room_id: 1,
  amenity_id: 4
)

RoomAmenity.create!(
  room_id: 1,
  amenity_id: 2
)

RoomAmenity.create!(
  room_id: 2,
  amenity_id: 1
)

RoomAmenity.create!(
  room_id: 2,
  amenity_id: 3
)

RoomAmenity.create!(
  room_id: 2,
  amenity_id: 4
)

RoomAmenity.create!(
  room_id: 3,
  amenity_id: 1
)

RoomAmenity.create!(
  room_id: 3,
  amenity_id: 5
)

RoomAmenity.create!(
  room_id: 3,
  amenity_id: 4
)

RoomAmenity.create!(
  room_id: 4,
  amenity_id: 2
)

RoomAmenity.create!(
  room_id: 4,
  amenity_id: 3
)

RoomAmenity.create!(
  room_id: 4,
  amenity_id: 4
)

RoomAmenity.create!(
  room_id: 5,
  amenity_id: 4
)

RoomAmenity.create!(
  room_id: 5,
  amenity_id: 3
)
RoomAmenity.create!(
  room_id: 5,
  amenity_id: 1
)

Booking.create!(
  user_id: 4,
  booking_code: "Pb0189",
  booking_date: Time.zone.now,
  status: 0
)

# ===== RESET PHẦN BOOKING/REQUEST/LINK =====
RoomAvailabilityRequest.delete_all
Request.delete_all
Booking.delete_all

# ===== ĐẢM BẢO CÓ ROOM_AVAILABILITY CHO 60 NGÀY TỚI =====
start_date = Date.today
end_date   = start_date + 60

Room.find_each do |room|
  base = room.room_type&.price.to_d rescue 100.to_d
  (start_date...end_date).each do |d|
    RoomAvailability.find_or_create_by!(room_id: room.id, available_date: d) do |ra|
      ra.price = base + [0, 10, 20, 30].sample
    end
  end
end

NEW_BOOKINGS = 15
users = User.limit(10).to_a
rooms = Room.all.to_a
raise "Cần có Room để seed!" if rooms.empty?
raise "Cần có User để seed!" if users.empty?

# Request statuses không được overlap
NON_OVERLAP_REQ_STATUSES = %i[pending confirmed checked_in checked_out].freeze

# Map booking -> request statuses cho phép
ALLOWED_REQ_BY_BOOKING = {
  draft:     %i[draft],
  pending:   %i[pending],
  confirmed: %i[confirmed checked_in checked_out],
  cancelled: %i[cancelled],
  declined:  %i[declined],
  completed: %i[checked_out]
}.freeze

occupied = Hash.new { |h, k| h[k] = {} }

def pick_continuous_block(room_id:, min_day:, max_day:, nights:, active:, occupied:)
  50.times do
    d0 = rand(min_day..(max_day - nights))
    dates = (d0...(d0 + nights)).to_a
    if active
      next if dates.any? { |d| occupied.dig(room_id, d) }
    end
    return dates
  end
  nil
end

def enum_val(klass, sym)
  key = sym.to_s
  h = klass.statuses
  raise "Enum #{klass.name} không có key #{key}" unless h.key?(key)
  h[key]
end

booking_states = Booking.statuses.keys.map(&:to_sym)
booking_states = booking_states - [:completed] if booking_states.include?(:completed)
cycle_states = (booking_states * ((NEW_BOOKINGS / booking_states.size) + 1)).first(NEW_BOOKINGS)
FORCE_COMPLETED_EVERY = 4
NEW_BOOKINGS.times do |i|
  code = "BK%04d" % (i + 1)
  user = users.sample
  booking_status = cycle_states[i]

  booking = Booking.create!(
    user_id:      user.id,
    booking_code: code,
    booking_date: Time.zone.now,
    status:       enum_val(Booking, booking_status)
  )

  # ép booking này phải hoàn tất?
  force_completed = (i % FORCE_COMPLETED_EVERY == 0)

  reqs = []
  rand(1..3).times do |ri|
    room = rooms.sample

    # nếu ép hoàn tất → mọi request đều checked_out
    if force_completed
      req_status = :checked_out
    else
      allowed_req_statuses = ALLOWED_REQ_BY_BOOKING.fetch(booking_status, %i[draft])
      req_status = allowed_req_statuses.sample
    end

    is_active = NON_OVERLAP_REQ_STATUSES.include?(req_status)

    nights = rand(1..4)
    min_day = start_date + 1
    max_day = start_date + 40

    dates = pick_continuous_block(
      room_id: room.id,
      min_day: min_day,
      max_day: max_day,
      nights: nights,
      active: is_active,
      occupied: occupied
    )

    if dates.nil?
      # nếu ép hoàn tất mà bí slot, vẫn degrade về draft để tránh kẹt seed
      req_status = :draft unless is_active && force_completed
      is_active  = NON_OVERLAP_REQ_STATUSES.include?(req_status)

      nights     = rand(1..3)
      dates = pick_continuous_block(
        room_id: room.id,
        min_day: min_day,
        max_day: max_day,
        nights: nights,
        active: is_active,
        occupied: occupied
      ) || (min_day...(min_day + nights)).to_a
    end

    check_in_date  = dates.first
    check_out_date = dates.last
    check_in_dt  = check_in_date.to_datetime.change(hour: 11)
    check_out_dt = check_out_date.to_datetime.change(hour: 16)

    guests = [[room.capacity, 4].compact.min, 1].max

    req = Request.create!(
      booking_id:        booking.id,
      room_id:           room.id,
      check_in:          check_in_dt,
      check_out:         check_out_dt,
      number_of_guests:  guests,
      status:            enum_val(Request, req_status),
      note:              "#{code}-#{room.room_number}-R#{ri+1}"
    )
    reqs << req

    dates.each do |d|
      ra = RoomAvailability.find_by!(room_id: room.id, available_date: d)
      RoomAvailabilityRequest.create!(room_availability_id: ra.id, request_id: req.id)
      occupied[room.id][d] = true if is_active
    end
  end

  # Nếu ép hoàn tất → chắc chắn set completed (nếu enum có)
  if defined?(Request) && reqs.any? && (force_completed || reqs.all? { |r| r.status == enum_val(Request, :checked_out) })
    booking.update!(status: enum_val(Booking, :completed)) if Booking.statuses.key?("completed")
  end
end

puts "Seed xong: #{Booking.count} bookings, #{Request.count} requests, #{RoomAvailabilityRequest.count} links."

# ===== THÊM GUESTS CHO CÁC REQUEST CHECKED_OUT =====
checked_out_requests = Request.where(status: Request.statuses[:checked_out])

checked_out_requests.each do |request|
  # Tạo guests dựa trên number_of_guests của request
  num_guests = [request.number_of_guests, 1].max
  
  num_guests.times do |i|
    guest_names = [
      "Nguyen Van A", "Tran Thi B", "Le Van C", "Pham Thi D", "Hoang Van E",
      "Vu Thi F", "Do Van G", "Ngo Thi H", "Bui Van I", "Dang Thi K"
    ]
    
    provinces = [
      "Ha Noi", "Ho Chi Minh", "Da Nang", "Hai Phong", "Can Tho",
      "Binh Duong", "Dong Nai", "Khanh Hoa", "Lam Dong", "Quang Nam"
    ]
    
    identity_types = ["national_id", "passport", "identity_number"]
    
    # Tạo số CCCD/passport ngẫu nhiên hợp lệ
    identity_type = identity_types.sample
    identity_number = case identity_type
    when "national_id", "identity_number"
      # CCCD 12 số
      "#{rand(100000000000..999999999999)}"
    when "passport"
      # Passport format: 1 chữ cái + 7 số
      "#{("a".."z").to_a.sample}#{rand(1000000..9999999)}"
    end
    
    Guest.create!(
      request: request,
      full_name: "#{guest_names.sample} #{i + 1}",
      identity_type: identity_type,
      identity_number: identity_number,
      identity_issued_date: rand(5.years.ago..1.year.ago).to_date,
      identity_issued_place: provinces.sample
    )
  end
end

# ===== THÊM REVIEWS CHO CÁC REQUEST CHECKED_OUT =====
checked_out_requests.each do |request|
  # Lấy user từ booking của request này
  user = request.booking.user
  
  # Tạo review ngẫu nhiên
  ratings = [3, 4, 5] # Chỉ tạo review tích cực
  rating = ratings.sample
  
  comments = [
    "Excellent service and comfortable room #{request.room&.room_number}!",
    "Great experience staying at room #{request.room&.room_number}. Will come back!",
    "Very satisfied with the service and cleanliness of room #{request.room&.room_number}.",
    "Good value for money. Room #{request.room&.room_number} was perfect for our stay.",
    "Professional staff and well-maintained facilities in room #{request.room&.room_number}.",
    "Highly recommend this hotel. Room #{request.room&.room_number} exceeded expectations.",
    "Peaceful and comfortable stay in room #{request.room&.room_number}."
  ]
  
  review_statuses = ["pending"] # 2/3 chance approved
  
  Review.create!(
    user: user,
    request: request,
    rating: rating,
    comment: comments.sample,
    review_status: review_statuses.sample
  )
end

puts "Đã thêm #{Guest.count} guests và #{Review.count} reviews cho các request checked_out."

puts "=== Update RoomAvailabilities for pending/confirm requests ==="

Request.includes(:room, :booking).where(status: [:pending, :confirmed, :checked_in, :checked_out]).find_each do |req|
  if req.room.present? && req.check_in.present? && req.check_out.present?
    booking_dates = (req.check_in.to_date..req.check_out.to_date).to_a

    updated = req.room.room_availabilities
                      .where(available_date: booking_dates)
                      .update_all(is_available: false)

    puts "Request ##{req.id} (Booking ##{req.booking_id}) → Blocked #{updated} dates"
  else
    puts "⚠️ Request ##{req.id} skipped (missing room or dates)"
  end
end

puts "=== Done updating RoomAvailabilities ==="
