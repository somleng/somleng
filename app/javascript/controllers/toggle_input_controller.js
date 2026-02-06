import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["enabledInput", "input", "hint"];

  connect() {
    this.toggleEnabled();
  }

  toggleEnabled() {
    const enabled = this.enabledInputTarget.checked;
    this.inputTarget.disabled = !enabled;

    if (this.hasHintTarget) {
      this.hintTarget.style.display = enabled ? "none" : "inline-block";
    }
  }
}
