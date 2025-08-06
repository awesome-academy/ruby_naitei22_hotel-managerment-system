import { Application } from "@hotwired/stimulus"
import BookingController from "./booking_controller"

const application = Application.start()

// Đăng ký controller
application.register("booking", BookingController)

// Debug mode (tắt khi production)
application.debug = false
window.Stimulus = application

export { application }
