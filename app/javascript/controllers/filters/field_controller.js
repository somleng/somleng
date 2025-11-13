import { Controller } from "@hotwired/stimulus";
import * as bootstrap from "bootstrap";

export default class extends Controller {
  static targets = ["switcher", "fieldInputsContainer"];

  connect() {
    this.toggle();
  }

  toggle() {
    let bsCollapse = new bootstrap.Collapse(this.fieldInputsContainerTarget, {
      toggle: false,
    });
    this.enabled ? bsCollapse.show() : bsCollapse.hide();

    this.fieldInputsContainerTarget
      .querySelectorAll("input, select, textarea")
      .forEach((element) => {
        element.disabled = !this.enabled;
      });
  }

  get enabled() {
    return this.switcherTarget.checked;
  }
}
