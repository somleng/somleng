import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["enabledInput", "input"];

  connect() {
    this.toggleEnabled();
  }

  toggleEnabled() {
    const enabled = this.enabledInputTarget.checked;
    this.inputTarget.disabled = !enabled;
  }
}
