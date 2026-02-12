import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="remove-nested-form"
export default class extends Controller {
  static targets = ["destroyElement"];

  NESTED_FORM_GROUP_SELECTOR = ".nested-form-group";
  DESTROY_BUTTON_SELECTOR = ".destroy-button";

  connect() {
    this.#toggleRemoveButtons();
  }

  remove(e) {
    e.preventDefault();

    this.element
      .querySelectorAll("input:not([type='hidden']), select, textarea")
      .forEach((el) => (el.disabled = true));

    this.element.style.display = "none";
    this.destroyElementTarget.value = "true";

    this.#toggleRemoveButtons();
  }

  #toggleRemoveButtons() {
    const activeNestedForms = this.#activeNestedForms();
    const hideRemoveButton = activeNestedForms.length <= 1;

    activeNestedForms.forEach((nestedForm) => {
      const removeButton = nestedForm.querySelector(this.DESTROY_BUTTON_SELECTOR);
      removeButton.classList.toggle("d-none", hideRemoveButton);
    });
  }

  #activeNestedForms() {
    const nestedFormGroup =
      this.element.closest(this.NESTED_FORM_GROUP_SELECTOR);

    const nestedForms = Array.from(
      nestedFormGroup.querySelectorAll(
        `[data-controller~='${this.identifier}']`,
      ),
    );

    const activeNestedForms = nestedForms.filter((nestedForm) => {
      const destroyField = nestedForm.querySelector(
        `[data-${this.identifier}-target='destroyElement']`,
      );

      return destroyField?.value !== "true" && nestedForm.style.display !== "none";
    });

    return activeNestedForms;
  }
}
