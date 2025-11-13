import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="remove-nested-form"
export default class extends Controller {
  static targets = ["element", "destroyElement"];

  remove(e) {
    e.preventDefault();

    this.elementTarget.style.display = "none";
    this.destroyElementTarget.value = "true";
  }
}
