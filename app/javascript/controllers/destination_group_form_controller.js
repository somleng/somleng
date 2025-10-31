import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="destination-group-form"
export default class extends Controller {
  static targets = ["catchAllInput", "nameInput", "prefixesInput"];
  static values = {
    catchAllName: String,
    catchAllPrefixes: String,
  };

  connect() {
    this.toggleCatchAll();
  }

  toggleCatchAll() {
    const isChecked = this.catchAllInputTarget.checked;

    if (isChecked) {
      this.nameInputTarget.value = this.catchAllNameValue;
      this.prefixesInputTarget.value = this.catchAllPrefixesValue;
    } else {
      this.nameInputTarget.value = "";
      this.prefixesInputTarget.value = "";
    }

    this.prefixesInputTarget.toggleAttribute("disabled", isChecked);
    this.nameInputTarget.toggleAttribute("disabled", isChecked);
  }
}
