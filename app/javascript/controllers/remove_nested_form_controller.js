import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="remove-nested-form"
export default class extends Controller {
  static targets = ["destroyElement"];

  remove(e) {
    e.preventDefault();

    this.element
      .querySelectorAll("input:not([type='hidden']), select, textarea")
      .forEach((el) => (el.disabled = true));

    this.element.style.display = "none";
    this.destroyElementTarget.value = "true";
  }
}
