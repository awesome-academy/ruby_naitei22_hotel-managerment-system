class BookingMailer < ApplicationMailer
  def booking_confirmation booking
    @booking = booking
    @user = booking.user

    mail to: @user.email, subject: t(".subject")
  end

  def booking_decline booking
    @booking = booking
    @user = booking.user

    mail to: @user.email, subject: t(".subject")
  end
end
