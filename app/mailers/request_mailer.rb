class RequestMailer < ApplicationMailer
  def checkin_reminder request
    @request = request
    @user = request.booking.user

    mail to: @user.email, subject: t(".subject")
  end
end
