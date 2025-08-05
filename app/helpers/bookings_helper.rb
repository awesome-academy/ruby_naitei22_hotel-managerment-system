module BookingsHelper
  def room_already_booked? _booking, _room
    return false if @current_booking.nil?

    @current_booking.requests.any? do |req|
      req.room_id == @room.id && !req.check_in.nil?
    end
  end

  def request_total_price request
    request.room_availability_requests.sum {|rar| rar.room_availability.price}
  end
end
