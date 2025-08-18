document.addEventListener("turbo:load", () => {
  const checkInInput = document.querySelector('[name$="[check_in]"]');
  const checkOutInput = document.querySelector('[name$="[check_out]"]');
  const nightDisplay = document.getElementById("total-night");
  const priceDisplay = document.getElementById("total-price");

  // Lấy các text từ div cha
  const priceBreakdown = document.querySelector(".price-breakdown");
  const labels = {
    nights: priceBreakdown.dataset.nightsLabel,
    totalPrice: priceBreakdown.dataset.totalPriceLabel,
    selectDates: priceBreakdown.dataset.selectDatesLabel,
    errorPrice: priceBreakdown.dataset.errorPriceLabel,
    dash: priceBreakdown.dataset.dash
  };

  function fetchPrice() {
    const checkIn = checkInInput.value;
    const checkOut = checkOutInput.value;

    if (checkIn && checkOut) {
      const roomId = priceDisplay.dataset.roomId;

      fetch(`/rooms/${roomId}/calculate_price?check_in=${checkIn}&check_out=${checkOut}`)
        .then(response => response.json())
        .then(data => {
          if (data.total_price != null) {
            nightDisplay.textContent = `${labels.nights} ${data.nights}`;
            priceDisplay.textContent = `${labels.totalPrice} $${data.total_price.toLocaleString()}`;
          } else {
            nightDisplay.textContent = `${labels.nights} ${labels.dash}`;
            priceDisplay.textContent = labels.selectDates;
          }
        })
        .catch(() => {
          nightDisplay.textContent = `${labels.nights} ${labels.dash}`;
          priceDisplay.textContent = labels.errorPrice;
        });
    }
  }

  checkInInput.addEventListener("change", fetchPrice);
  checkOutInput.addEventListener("change", fetchPrice);
});
