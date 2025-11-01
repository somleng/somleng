import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tariff-bundle-selection"
export default class extends Controller {
  static targets = ["tariffBundleInput", "tariffPackageInput"];

  connect() {
    this.changeTariffBundle();
  }

  changeTariffBundle() {
    const selectedBundle = this.tariffBundleInputTarget.selectedOptions[0];
    if (!selectedBundle) return;

    const tariffPackageData = selectedBundle.dataset.tariffPackages;
    if (!tariffPackageData) return;

    const tariffPackages = JSON.parse(tariffPackageData);

    this.tariffPackageInputTargets.forEach((select) => {
      const category = select.dataset.category;
      if (!category) return;

      const packageId = tariffPackages[category] || "";
      select.value = packageId;

      select.dispatchEvent(
        new CustomEvent("external:set-value", {
          bubbles: true,
          detail: { value: packageId },
        })
      );
    });
  }

  changeTariffPackage() {
    this.tariffBundleInputTarget.value = "";
  }
}
