import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tariff-bundle-selection"
export default class extends Controller {
  static targets = ["tariffBundleInput", "tariffPlanInput"];

  connect() {
    this.changeTariffBundle();
  }

  changeTariffBundle() {
    const selectedBundle = this.tariffBundleInputTarget.selectedOptions[0];
    if (!selectedBundle) return;

    const tariffPlanData = selectedBundle.dataset.tariffPlans;
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
    this.tariffBundleInputTarget.value = "";
  }
}
