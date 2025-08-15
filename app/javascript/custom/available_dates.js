// app/javascript/custom/available_dates.js
document.addEventListener("turbo:load", () => {
  const checkInInput = document.querySelector('[name$="[check_in]"]');
  const checkOutInput = document.querySelector('[name$="[check_out]"]');
  if (!checkInInput || !checkOutInput) return;

  const unavailableMessage = checkInInput.dataset.unavailableMessage;

  // Convert tất cả available dates thành chuỗi YYYY-MM-DD để so sánh
  const availableDates = JSON.parse(checkInInput.dataset.availableDates || "[]")
    .map(dateStr => {
      const d = new Date(dateStr);
      d.setHours(0, 0, 0, 0);
      return d.toISOString().split("T")[0]; // "YYYY-MM-DD"
    });

  // Giới hạn chọn tối đa 2 tháng tới
  const maxDate = new Date();
  maxDate.setMonth(maxDate.getMonth() + 2);
  maxDate.setDate(0);

  // Khởi tạo flatpickr cho check_out
  const checkOutFp = flatpickr(checkOutInput, {
    dateFormat: "Y/m/d",
    minDate: "today",
    maxDate: maxDate,
    enable: availableDates,
    allowInput: false,
    onChange(selectedDates) {
      const checkInDate = checkInFp.selectedDates[0];
      const checkOutDate = selectedDates[0];
      if (!checkInDate || !checkOutDate) return;

      let d = new Date(checkInDate);
      d.setHours(0, 0, 0, 0);
      const end = new Date(checkOutDate);
      end.setHours(0, 0, 0, 0);

      // Kiểm tra trong khoảng có ngày không khả dụng
      while (d <= end) {
        const dStr = d.toISOString().split("T")[0];
        if (!availableDates.includes(dStr)) {
          alert(unavailableMessage);
          checkOutFp.clear();
          return;
        }
        d.setDate(d.getDate() + 1);
      }
    }
  });

  // Khởi tạo flatpickr cho check_in
  const checkInFp = flatpickr(checkInInput, {
    dateFormat: "Y/m/d",
    minDate: "today",
    maxDate: maxDate,
    enable: availableDates,
    allowInput: false,
    onChange(selectedDates) {
      if (!selectedDates.length) return;

      const minCheckOut = new Date(selectedDates[0]);
      minCheckOut.setHours(0, 0, 0, 0);

      // Chỉ cho phép check_out >= check_in
      const filteredDates = availableDates.filter(dateStr => {
        const d = new Date(dateStr);
        d.setHours(0, 0, 0, 0);
        return d >= minCheckOut;
      });

      checkOutFp.set("minDate", minCheckOut);
      checkOutFp.set("enable", filteredDates);

      // Reset check_out nếu đang chọn ngày không hợp lệ
      const currentOut = checkOutFp.selectedDates[0];
      if (!currentOut || currentOut <= selectedDates[0]) {
        checkOutFp.clear();
      }
    }
  });
});
