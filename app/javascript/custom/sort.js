document.addEventListener("turbo:load", function () {
  document.querySelectorAll("th[data-sortable]").forEach(th => {
    th.addEventListener("click", function () {
      const table = this.closest("table");
      const tbody = table.querySelector("tbody");
      const rows = Array.from(tbody.querySelectorAll("tr"));
      
      const colIndex = Array.from(this.parentNode.children).indexOf(this);
      const currentOrder = this.dataset.order || "asc";
      const newOrder = currentOrder === "asc" ? "desc" : "asc";
      this.dataset.order = newOrder;

      rows.sort((a, b) => {
        let valA = a.children[colIndex].innerText.trim();
        let valB = b.children[colIndex].innerText.trim();

        // Nếu là số thì chuyển sang float
        const numA = parseFloat(valA.replace(/\./g, "").replace(",", "."));
        const numB = parseFloat(valB.replace(/\./g, "").replace(",", "."));
        if (!isNaN(numA) && !isNaN(numB)) {
          valA = numA;
          valB = numB;
        }

        if (valA < valB) return newOrder === "asc" ? -1 : 1;
        if (valA > valB) return newOrder === "asc" ? 1 : -1;
        return 0;
      });

      rows.forEach(row => tbody.appendChild(row));
      console.log(`Sorted column ${colIndex} (${newOrder}) in table`, table);
    });
  });
});
