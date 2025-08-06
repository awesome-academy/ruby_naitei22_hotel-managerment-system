// app/javascript/modal-handler.js (ví dụ)
document.addEventListener("turbo:load", function () {
  // Helper show/hide
  function showModal(el) {
    if (!el) return;
    el.classList.remove("hidden");
    el.classList.add("show");
    // disable page scroll while modal open
    document.documentElement.style.overflow = "hidden";
    document.body.style.overflow = "hidden";
  }
  function hideModal(el) {
    if (!el) return;
    el.classList.remove("show");
    el.classList.add("hidden");
    // restore page scroll if no modal visible
    if (!document.querySelector(".custom-modal.show")) {
      document.documentElement.style.overflow = "";
      document.body.style.overflow = "";
    }
  }

  // Track last custom modal that was open (so we can restore it after review closes)
  let lastCustomModal = null;

  // Open booking modal (custom)
  document.querySelectorAll(".open-request-modal").forEach(btn => {
    btn.addEventListener("click", function () {
      const modalId = this.dataset.modalId;
      const modal = document.getElementById(modalId);
      if (!modal) return;
      showModal(modal);
    });
  });

  // Open review modal (custom) — this DOES NOT use bootstrap
  document.querySelectorAll(".open-review-modal").forEach(btn => {
    btn.addEventListener("click", function (e) {
      const modalId = this.dataset.modalId; // ex: "reviewModal-3"
      const reviewModal = document.getElementById(modalId);
      if (!reviewModal) return;

      // If there is some custom modal currently shown (booking modal), hide and remember it
      const openCustom = document.querySelector(".custom-modal.show");
      if (openCustom && openCustom !== reviewModal) {
        lastCustomModal = openCustom;
        hideModal(openCustom);
      } else {
        lastCustomModal = null;
      }

      showModal(reviewModal);
    });
  });

  // Close modal when clicking .close-modal buttons
  document.querySelectorAll(".close-modal").forEach(closeBtn => {
    closeBtn.addEventListener("click", function () {
      const modalId = this.dataset.modalId;
      const modal = document.getElementById(modalId);
      hideModal(modal);

      // restore previous booking modal if any
      if (lastCustomModal) {
        showModal(lastCustomModal);
        lastCustomModal = null;
      }
    });
  });

  // Close modal when clicking on overlay (click outside .custom-modal-content)
  document.querySelectorAll(".custom-modal").forEach(modal => {
    modal.addEventListener("click", function (event) {
      // if click on the modal itself (not inside .custom-modal-content), close it
      if (event.target === modal) {
        hideModal(modal);
        if (lastCustomModal) {
          showModal(lastCustomModal);
          lastCustomModal = null;
        }
      }
    });
  });

  // Close on Escape
  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") {
      const open = document.querySelector(".custom-modal.show");
      if (open) {
        hideModal(open);
        if (lastCustomModal) {
          showModal(lastCustomModal);
          lastCustomModal = null;
        }
      }
    }
  });
});
