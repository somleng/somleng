import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tariff-schedule-form"

export default class extends Controller {
  static targets = ["categoryInput", "nameInputGroupText"];

  connect() {
    this.toggleCategory();
  }

  toggleCategory() {
    if (!this.hasCategoryInputTarget) return;
    if (!this.hasNameInputGroupTextTarget) return;
    if (!this.categoryInputTarget.value.length) return;

    const categoryText =
      this.categoryInputTarget.selectedOptions?.[0]?.text?.trim() ?? "";
    this.nameInputGroupTextTarget.textContent = categoryText;
  }
}
