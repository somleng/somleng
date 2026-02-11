import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tariff-package-selection"
export default class extends Controller {
  static targets = ["tariffPackageInput", "tariffPlanInputGroup"];
  static values = {
    plans: Object,
  };

  connect() {
    this.changeTariffPackage();
  }

  changeTariffPackage() {
    if (!this.hasTariffPackageInputTarget) return;

    const selectedPackage = this.tariffPackageInputTarget.value;
    if (!selectedPackage) return;

    const plans = this.plansValue[selectedPackage];

    this.tariffPlanInputGroupTargets.forEach((inputGroup) => {
      const select = inputGroup.querySelector(".plan-id-input");
      const toggleInput = inputGroup.querySelector(".toggle-input");

      const category = select.dataset.category;
      const planId = plans[category] || "";

      const disabled = planId === "";
      toggleInput.checked = !disabled;
      select.disabled = disabled;
      select.value = planId;

      select.dispatchEvent(
        new CustomEvent("value-set", {
          bubbles: true,
          detail: { value: planId },
        })
      );
    });
  }

  changeTariffPlan() {
    this.tariffPackageInputTarget.value = "";

    this.tariffPackageInputTarget.dispatchEvent(
      new CustomEvent("value-set", {
        bubbles: true,
        detail: { value: "" },
      })
    );
  }
}
