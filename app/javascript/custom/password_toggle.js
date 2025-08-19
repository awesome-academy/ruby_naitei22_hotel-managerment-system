document.addEventListener("turbo:load", function () {
  const toggles = document.querySelectorAll(".toggle-password");

  toggles.forEach(toggle => {
    toggle.addEventListener("click", () => {
      const input = toggle.parentElement.querySelector("input");

      if (input && input.type === "password") {
        input.type = "text";
        toggle.classList.remove("fa-eye");
        toggle.classList.add("fa-eye-slash");
      } else if (input) {
        input.type = "password";
        toggle.classList.remove("fa-eye-slash");
        toggle.classList.add("fa-eye");
      }
    });
  });
});
