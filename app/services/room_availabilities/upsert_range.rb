module RoomAvailabilities
  class UpsertRange
    def initialize room, from:, to:, price:
      @room  = room
      @from  = from
      @to    = to
      @price = price
    end

    def call
      existing = load_existing_availabilities
      update_existing!(existing)
      create_missing!(existing)
    end

    private

    def load_existing_availabilities
      @room.room_availabilities.where(available_date: @from..@to)
    end

    def update_existing! existing
      return if existing.empty?

      existing.where(is_available: true)
              .update_all(price: @price, updated_at: Time.current)
    end

    def create_missing! existing
      existing_dates = existing.pluck(:available_date)
      missing_dates = (@from..@to).reject do |date|
        existing_dates.include?(date)
      end
      return if missing_dates.empty?

      rows = missing_dates.map do |date|
        {
          room_id: @room.id,
          available_date: date,
          is_available: true,
          price: @price,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      RoomAvailability.insert_all!(rows)
    end
  end
end
