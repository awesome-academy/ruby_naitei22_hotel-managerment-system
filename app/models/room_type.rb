class RoomType < ApplicationRecord
  has_many :rooms, dependent: :destroy
end
