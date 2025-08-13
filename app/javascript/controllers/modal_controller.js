import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  connect() {}
  close(e) {
    e.preventDefault();
    // Remove from parent
    const modal = document.getElementById("modal");
    modal.innerHTML = "";

    // Remove the src attribute from the modal
    modal.removeAttribute("src");

    // Remove complete attribute
    modal.removeAttribute("complete");
  }
}
