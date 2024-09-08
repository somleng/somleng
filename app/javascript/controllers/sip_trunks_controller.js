import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "authenticationModeInput",
    "countrySelectInput",
    "ipAddressAuthenticationSection",
    "regionInput",
    "regionHint",
  ];

  connect() {
    this.toggleAuthenticationMode();
    this.toggleRegion();
  }

  toggleAuthenticationMode() {
    const element = this.authenticationModeInputTargets.find(
      (element) => element.checked
    );

    if (element.value == "client_credentials") {
      if (!("selectedCountry" in this.countrySelectInputTarget.dataset)) {
        this.countrySelectInputTarget.value =
          this.countrySelectInputTarget.dataset.defaultCountry;
      }
      this.ipAddressAuthenticationSectionTargets.forEach(
        (target) => (target.style.display = "none")
      );
    } else {
      this.countrySelectInputTarget.value =
        this.countrySelectInputTarget.dataset.selectedCountry;
      this.ipAddressAuthenticationSectionTargets.forEach(
        (target) => (target.style.display = "block")
      );
    }
  }

  toggleRegion() {
    const element = this.regionInputTarget;
    const hint = this.regionHintTarget;
    const regionNameHint = hint.querySelector(hint.dataset.regionNameTarget);
    const ipAddressesHint = hint.querySelector(hint.dataset.ipAddressesTarget);
    const selectedRegion = element.options[element.selectedIndex];
    regionNameHint.textContent = selectedRegion.text;
    ipAddressesHint.textContent = selectedRegion.dataset.ipAddresses;
  }
}
