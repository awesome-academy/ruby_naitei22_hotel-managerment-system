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
      return d.toISOString().split("T")[0]; // "YYYY-MM-DD"
    });
  
  // Giới hạn chọn tối đa 2 tháng tới
  const maxDate = new Date();
  maxDate.setMonth(maxDate.getMonth() + 4);
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
      const end = new Date(checkOutDate);

      // Kiểm tra trong khoảng có ngày không khả dụng
      while (d <= end) {
        const dStr = formatDateLocal(d); // 👈 không dùng toISOString nữa
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

      // Chỉ cho phép check_out >= check_in
      const filteredDates = availableDates.filter(dateStr => {
        const d = new Date(dateStr);
        return d >= minCheckOut;
      });

      checkOutFp.set("minDate", minCheckOut);
      checkOutFp.set("enable", filteredDates);

      // Reset check_out nếu đang chọn ngày không hợp lệ
      const currentOut = checkOutFp.selectedDates[0];
      if (!currentOut || currentOut < selectedDates[0]) {
        checkOutFp.clear();
      }
    }
  });

  function formatDateLocal(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
  };
});
