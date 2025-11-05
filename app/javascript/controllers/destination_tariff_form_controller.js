import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="destination-tariff-form"
export default class extends Controller {
  static targets = ["rateUnit"];
  static values = {
    rateUnitByCategory: Object,
  };

  connect() {
    const form = this.element.closest("form");
    if (!form) return;

    this.#updateRateUnit(form.dataset.selectedCategory);

    form.addEventListener("tariff-schedule-category-changed", (event) => {
      this.#updateRateUnit(event.detail.category);
    });
  }

  #updateRateUnit(category) {
    if (!category || !this.hasRateUnitTarget) return;

    const rateUnit = this.rateUnitByCategoryValue[category];
    this.rateUnitTarget.textContent = rateUnit;
  }
}
