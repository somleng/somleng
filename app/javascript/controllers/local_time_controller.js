import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="local-time"
export default class extends Controller {
  connect() {
    this.element.textContent = new Intl.DateTimeFormat(navigator.language, {
      dateStyle: "medium",
      timeStyle: "long",
    }).format(new Date(this.element.textContent));
  }
}
