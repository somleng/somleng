import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "authenticationModeInput", "countrySelectInput", "ipAddressAuthenticationSection" ]

  connect() {
    this.toggleAuthenticationMode();
  }

  toggleAuthenticationMode() {
    const element = this.authenticationModeInputTargets.find((element) => element.checked)

    if (element.value == "client_credentials") {
      if (!("selectedCountry" in this.countrySelectInputTarget.dataset)) {
        this.countrySelectInputTarget.value = this.countrySelectInputTarget.dataset.defaultCountry
      }
      this.ipAddressAuthenticationSectionTargets.forEach((target) => target.style.display = 'none');
    } else {
      this.countrySelectInputTarget.value = this.countrySelectInputTarget.dataset.selectedCountry
      this.ipAddressAuthenticationSectionTargets.forEach((target) => target.style.display = 'block');
    }
  }
}
