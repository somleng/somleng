import { Controller } from "@hotwired/stimulus";
import Choices from "choices.js";

export default class extends Controller {
  connect() {
    if (this.element._choicesInitialized) return;

    const options = JSON.parse(this.element.dataset.choicesOptions || "{}");
    const instance = new Choices(this.element, options);

    this.element._choicesInitialized = true;

    const wrapper = this.element.closest(".choices");
    if (this.element.classList.contains("is-invalid"))
      wrapper.classList.add("is-invalid");

    this.element.addEventListener("external:set-value", (e) => {
      if (e.detail.value) {
        instance.setChoiceByValue(e.detail.value);
      }
    });
  }
}
