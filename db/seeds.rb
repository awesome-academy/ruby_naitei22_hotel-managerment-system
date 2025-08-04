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
  password_confirmation: "123",
)

10.times do |n|
  User.create!(
    name: "User #{n + 1}",
    email: "user#{n + 1}@example.com",
    password: "password",
    password_confirmation: "password",
  )
end

