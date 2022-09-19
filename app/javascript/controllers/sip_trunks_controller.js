import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "authenticationModeInput", "ipAddressAuthenticationSection" ]

  connect() {
    this.toggleAuthenticationMode();
  }

  toggleAuthenticationMode(event) {
    if (event.target.value == "client_credentials") {
      this.ipAddressAuthenticationSectionTarget.style.display = 'none';
    } else {
      this.ipAddressAuthenticationSectionTarget.style.display = 'block';
    }
  }
}
