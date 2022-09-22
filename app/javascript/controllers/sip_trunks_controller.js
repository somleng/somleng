import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "authenticationModeInput", "ipAddressAuthenticationSection" ]

  connect() {
    this.toggleAuthenticationMode();
  }

  toggleAuthenticationMode() {
    const element = this.authenticationModeInputTargets.find((element) => element.checked)
    if (element.value == "client_credentials") {
      this.ipAddressAuthenticationSectionTarget.style.display = 'none';
    } else {
      this.ipAddressAuthenticationSectionTarget.style.display = 'block';
    }
  }
}
