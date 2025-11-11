import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tariff-plan-tier-form"
export default class extends Controller {
  static targets = ["tariffScheduleInput"];
  static values = {
    tariffSchedulesByCategory: Object,
  };

  connect() {
    const form = this.element.closest("form");
    if (!form) return;

    this.#updateTariffSchedulesOptionsForSelect(form.dataset.selectedCategory);

    form.addEventListener("tariff-category-changed", (event) => {
      this.#updateTariffSchedulesOptionsForSelect(event.detail.category);
    });
  }

  #updateTariffSchedulesOptionsForSelect(category) {
    if (
      !this.hasTariffScheduleInputTarget ||
      this.tariffScheduleInputTarget.disabled
    ) {
      return;
    }

    const select = this.tariffScheduleInputTarget;
    const schedules = this.tariffSchedulesByCategoryValue[category] || [];

    console.log(schedules);

    // Preserve prompt (usually the first option with empty value)
    const promptOption = select.querySelector('option[value=""]');

    // Clear all current options
    select.innerHTML = "";

    // Reinsert preserved prompt if any
    if (promptOption) {
      select.appendChild(promptOption);
    }

    schedules.forEach(([name, id]) => {
      const option = document.createElement("option");
      option.value = id;
      option.textContent = name;
      select.appendChild(option);
    });

    if (promptOption) {
      select.value = "";
    } else if (select.options.length > 0) {
      select.selectedIndex = 0;
    }

    select.dispatchEvent(
      new CustomEvent("options-changed", {
        bubbles: true,
      })
    );
  }
}
