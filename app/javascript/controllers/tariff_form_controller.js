import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tariff-form"
export default class extends Controller {
  static targets = [
    "ratesSection",
    "categoryInput",
    "messageRateInput",
    "messageRateInputWrapper",
    "callPerMinuteRateInput",
    "callPerMinuteRateInputWrapper",
    "connectionFeeInput",
    "connectionFeeInputWrapper",
  ];

  connect() {
    this.toggleCategory();
  }

  toggleCategory() {
    const category = this.categoryInputTarget.value;
    const isMessage = category === "message";
    const isCall = category === "call";

    this.ratesSectionTarget.classList.toggle("d-none", !category.length);

    this.#enableInput(
      this.messageRateInputTarget,
      this.messageRateInputWrapperTarget,
      isMessage
    );
    this.#enableInput(
      this.callPerMinuteRateInputTarget,
      this.callPerMinuteRateInputWrapperTarget,
      isCall
    );
    this.#enableInput(
      this.connectionFeeInputTarget,
      this.connectionFeeInputWrapperTarget,
      isCall
    );
  }

  #enableInput(element, wrapper, enabled) {
    wrapper.classList.toggle("d-none", !enabled);
    element.disabled = !enabled;
    if (!enabled) {
      element.value = "";
    }
  }
}
