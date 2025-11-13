import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["switcher", "badge"];

  connect() {
    this.toggle();
  }

  toggle() {
    this.badgeTarget.innerHTML = this.switcherTargets.filter(
      (e) => e.checked
    ).length;
  }
}
