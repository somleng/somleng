import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tariff-package-wizard"
export default class extends Controller {
  static targets = ["enabledInput", "rateInput"];

  connect() {
    this.toggleEnabled();
  }

  toggleEnabled() {
    const enabled = this.enabledInputTarget.checked;
    this.rateInputTarget.disabled = !enabled;
  }
}
