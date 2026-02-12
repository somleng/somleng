import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="remove-nested-form"
export default class extends Controller {
  static targets = ["destroyElement"];

  NESTED_FORM_GROUP_SELECTOR = ".nested-form-group";
  REMOVE_BUTTON_SELECTOR = ".remove-button";

  connect() {
    this.toggleRemoveButton();
  }

  remove(e) {
    e.preventDefault();

    this.element
      .querySelectorAll("input:not([type='hidden']), select, textarea")
      .forEach((el) => (el.disabled = true));

    this.element.classList.add("d-none");
    this.destroyElementTarget.value = "true";

    this.toggleRemoveButton();
  }

  toggleRemoveButton() {
    const activeNestedForms = this.#activeNestedForms();
    const hideButton = activeNestedForms.length <= 1;

    activeNestedForms.forEach((nestedForm) => {
      const removeButton = nestedForm.querySelector(this.REMOVE_BUTTON_SELECTOR);
      removeButton.classList.toggle("d-none", hideButton);
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
