import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tariff-package-selection"
export default class extends Controller {
  static targets = ["tariffPackageInput", "tariffPlanInput"];
  static values = {
    plans: Object,
  };

  connect() {
    this.changeTariffPackage();
  }

  changeTariffPackage() {
    const selectedPackage = this.tariffPackageInputTarget.value;
    if (!selectedPackage) return;

    const plans = this.plansValue[selectedPackage];

    this.tariffPlanInputTargets.forEach((select) => {
      const category = select.dataset.category;
      if (!category) return;

      const planId = plans[category] || "";
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
