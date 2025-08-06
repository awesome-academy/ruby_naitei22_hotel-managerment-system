document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".toggle-review").forEach(link => {
    link.addEventListener("click", (e) => {
      e.preventDefault();
      const id = link.dataset.id;
      const container = document.querySelector(`#review-${id}`);
      const shortText = container.querySelector(".short-text");
      const fullText = container.querySelector(".full-text");

      const seeMore = link.dataset.seeMore;
      const seeLess = link.dataset.seeLess;

      if (fullText.style.display === "none") {
        shortText.style.display = "none";
        fullText.style.display = "inline";
        link.textContent = seeLess;
      } else {
        shortText.style.display = "inline";
        fullText.style.display = "none";
        link.textContent = seeMore;
      }
    });
  });
});
