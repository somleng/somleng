import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tariff-schedule-form"

export default class extends Controller {
  static targets = ["categoryInput", "nameInput", "descriptionInput"];

  connect() {
    this.defaultNamePlaceholder = this.nameInputTarget.placeholder || "";
    this.defaultDescriptionPlaceholder =
      this.descriptionInputTarget.placeholder || "";
    this.toggleCategory();
  }

  toggleCategory() {
    if (!this.categoryInputTarget.value.length) return;

    const categoryText =
      this.categoryInputTarget.selectedOptions?.[0]?.text?.trim() ?? "";

    this.nameInputTarget.placeholder = this.#toSentenceCase(
      this.#buildPlaceholder(categoryText, this.defaultNamePlaceholder)
    );
    this.descriptionInputTarget.placeholder = this.#toSentenceCase(
      this.#buildPlaceholder(categoryText, this.defaultDescriptionPlaceholder)
    );
  }

  #toSentenceCase(str) {
    if (!str) return "";
    return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
  }

  #buildPlaceholder(categoryText, defaultPlaceholder) {
    return defaultPlaceholder
      ? `${defaultPlaceholder} ${categoryText}`
      : categoryText;
  }
}
