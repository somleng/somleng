import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["enabledInput", "container"];

  connect() {
    this.toggleEnabled();
  }

  toggleEnabled() {
    const enabled = this.enabledInputTarget.checked;
    this.containerTarget.style.display = enabled ? "block" : "none";
  }
}
