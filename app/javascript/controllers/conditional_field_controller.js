import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="conditional-field"
export default class extends Controller {
  static targets = ["source", "input"];
  static values = {
    disableWhen: String,
    clearOnDisable: { type: Boolean, default: true },
  };

  connect() {
    this.toggle();
  }

  toggle() {
    const currentValue = this.currentSourceValue;
    const shouldDisable = currentValue === this.disableWhenValue;

    this.inputTargets.forEach((input) => {
      input.disabled = shouldDisable;
      if (shouldDisable && this.clearOnDisableValue) {
        input.value = "";
      }
    });
  }

  get currentSourceValue() {
    const checkedTarget = this.sourceTargets.find(
      (target) =>
        target.checked ||
        (target.type !== "radio" && target.type !== "checkbox"),
    );

    return checkedTarget ? checkedTarget.value : null;
  }
}
