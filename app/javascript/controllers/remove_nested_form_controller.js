import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="remove-nested-form"
export default class extends Controller {
  static targets = ["destroyElement"];

  NESTED_FORM_GROUP_SELECTOR = ".nested-form-group";
  DESTROY_BUTTON_SELECTOR = ".destroy-button";

  connect() {
    this.toggleDestroyButtons();
  }

  remove(e) {
    e.preventDefault();

    this.element
      .querySelectorAll("input:not([type='hidden']), select, textarea")
      .forEach((el) => (el.disabled = true));

    this.element.classList.add("d-none");
    this.destroyElementTarget.value = "true";

    this.toggleDestroyButtons();
  }

  toggleDestroyButtons() {
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
        `[data-controller~='${this.identifier}']:not([class*='d-none'])`,
      ),
    );

    return nestedForms;
  }
}
