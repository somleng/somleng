import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tariff-package-selection"
export default class extends Controller {
  static targets = ["tariffPackageInput", "tariffPlanInput"];

  connect() {
    this.changeTariffPackage();
  }

  changeTariffPackage() {
    const selectedPackage = this.tariffPackageInputTarget.selectedOptions[0];
    if (!selectedPackage) return;

    const tariffPlanData = selectedPackage.dataset.tariffPlans;
    if (!tariffPlanData) return;

    const tariffPlans = JSON.parse(tariffPlanData);

    this.tariffPlanInputTargets.forEach((select) => {
      const category = select.dataset.category;
      if (!category) return;

      const planId = tariffPlans[category] || "";
      select.value = planId;

      select.dispatchEvent(
        new CustomEvent("external:set-value", {
          bubbles: true,
          detail: { value: planId },
        })
      );
    });
  }

  changeTariffPlan() {
    this.tariffPackageInputTarget.value = "";
  }
}
