# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# db/seeds.rb

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

Booking.create!(
  user_id: 4,
  booking_code: "Pb0189",
  booking_date: Time.zone.now,
  status: 0
)

Booking.create!(
  user_id: 2,
  booking_code: "ws6537",
  booking_date: Time.zone.now,
  status: 0
)

Booking.create!(
  user_id: 1,
  booking_code: "ru4855",
  booking_date: Time.zone.now,
  status: 0
)

Request.create!(
  booking_id: 1,
  check_in: "2025-08-08 02:20:41.402071",
  check_out: "2025-08-13 02:20:41.402071",
  number_of_guests: 3,
  status: 0,
  note: "Help man plan bank look generation."
)

Request.create!(
  booking_id: 2,
  check_in: "2025-08-14 02:20:41.402136",
  check_out: "2025-08-19 02:20:41.402136",
  number_of_guests: 1,
  status: 0,
  note: "Move generation officer trade reduce police finally cell."
)

Request.create!(
  booking_id: 3,
  check_in: "2025-08-14 02:20:41.402159",
  check_out: "2025-08-18 02:20:41.402159",
  number_of_guests: 4,
  status: 0,
  note: "Plant in huge what stay watch."
)

Review.create!(
  user_id: 1,
  request_id: 2,
  rating: 4,
  comment: "Have present statement leave.",
  review_status: 1
)

Review.create!(
  user_id: 2,
  request_id: 2,
  rating: 4,
  comment: "Good source clearly economic tend. Century Mrs message yard writer development.",
  review_status: 1
)

Review.create!(
  user_id: 5,
  request_id: 3,
  rating: 4,
  comment: "Or voice rise Mrs. Home but begin parent pass better account. Hour agent expert budget pass accept positive according.",
  review_status: 1
)
