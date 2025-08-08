User.create!(
  name: "Admin",
  email: "admin@gmail.com",
  password: "123",
  phone: "729-551-3035",
  role: 1,
  activated: true,
  activated_at: Time.zone.now
)
User.create!(
  name: "Dennis Foley",
  email: "vickiwilliams@levy.com",
  password: "Password@123",
  phone: "523-468-9226x96295",
  role: 0,
  activated: true,
  activated_at: Time.zone.now
)
User.create!(
  name: "Jared Snyder",
  email: "anthony41@lopez-fuller.com",
  password: "Password@123",
  phone: "306-359-9581x037",
  role: 0,
  activated: true,
  activated_at: Time.zone.now
)
User.create!(
  name: "Crystal Cox",
  email: "jonesdouglas@gmail.com",
  password: "Password@123",
  phone: "+1-388-501-3262x5359",
  role: 1,
  activated: true,
  activated_at: Time.zone.now
)
User.create!(
  name: "Alan Boyer",
  email: "douglasvaughn@yahoo.com",
  password: "Password@123",
  phone: "8809003047",
  role: 0,
  activated: true,
  activated_at: Time.zone.now
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
  status: 0,
  description: "Serve itself national back.",
  capacity: 1
)
Room.create!(
  room_number: "R002",
  room_type_id: 2,
  status: 0,
  description: "Evidence year threat anything. Why those talk relate.",
  capacity: 3
)
Room.create!(
  room_number: "R003",
  room_type_id: 3,
  status: 0,
  description: "Less hot war music. Care officer only ready attorney which. They reduce customer follow card.",
  capacity: 4
)
Room.create!(
  room_number: "R004",
  room_type_id: 1,
  status: 0,
  description: "State need can PM any. Light less tend capital training him.",
  capacity: 2
)
Room.create!(
  room_number: "R005",
  room_type_id: 2,
  status: 0,
  description: "Leg result direction beyond. Near southern determine however point. Last thus then.",
  capacity: 3
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

RoomAvailability.create!(room_id: Room.first.id, available_date: 3.days.from_now.to_date, price: 500)

# Booking cho user_id: 1
booking = Booking.create!(
  user_id: 1,
  booking_code: "RU1234",
  booking_date: Time.zone.now,
  status: 0
)

# Request gắn với booking trên
request = Request.create!(
  booking_id: booking.id,
  check_in: 3.days.from_now,
  check_out: 8.days.from_now,
  number_of_guests: 2,
  status: 0,
  note: "Need quiet room for business trip."
)

# Gắn request này với 1 room qua room_availability
room_availability = RoomAvailability.find_by(room_id: 1)
RoomAvailabilityRequest.create!(
  room_availability_id: room_availability.id,
  request_id: request.id
)

# Review cho request trên
Review.create!(
  user_id: 1,
  request_id: request.id,
  rating: 5,
  comment: "Very clean and quiet room. Great stay!",
  review_status: 1
)
