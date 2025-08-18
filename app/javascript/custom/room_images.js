document.addEventListener("turbo:load", () => {
  const swiperEl = document.querySelector(".mySwiper");
  if (swiperEl) {
    new Swiper(".mySwiper", {
      loop: true,
      pagination: {
        el: ".swiper-pagination",
        clickable: true,
      },
      navigation: {
        nextEl: ".swiper-button-next",
        prevEl: ".swiper-button-prev",
      },
      autoplay: {
        delay: 20000,
        disableOnInteraction: false,
      },
    });
  }
});
