import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tariff-schedule-form"

export default class extends Controller {
  static targets = ["categoryInput", "nameInputGroupText", "form"];

  connect() {
    this.toggleCategory();
  }

  toggleCategory() {
    if (!this.hasCategoryInputTarget) return;
    const categoryValue = this.categoryInputTarget.value;
    if (this.hasFormTarget) {
      this.formTarget.dataset.selectedCategory = categoryValue;

      this.formTarget.dispatchEvent(
        new CustomEvent("tariff-schedule-category-changed", {
          bubbles: true, // allow nested forms to catch it
          detail: { category: categoryValue },
        })
      );
    }

    if (!this.hasNameInputGroupTextTarget) return;

    const categoryText =
      this.categoryInputTarget.selectedOptions?.[0]?.text?.trim() ?? "";
    this.nameInputGroupTextTarget.textContent = categoryText;
  }
}
