import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["smsGatewayInput", "channelsInput"];
  static values = {
    availableChannels: Object,
  };

  changeSMSGateway() {
    if (this.smsGatewayInputTarget.disabled) {
      return;
    }

    const smsGatewayId = this.smsGatewayInputTarget.value;
    const availableChannels = this.availableChannelsValue[smsGatewayId] || [];

    const select = this.channelsInputTarget;

    // Preserve prompt (usually the first option with empty value)
    const promptOption = select.querySelector('option[value=""]');

    // Clear all current options
    select.innerHTML = "";

    // Reinsert preserved prompt if any
    if (promptOption) {
      select.appendChild(promptOption);
    }

    availableChannels.forEach((channel) => {
      const option = document.createElement("option");
      option.value = channel;
      option.textContent = channel;
      select.appendChild(option);
    });

    if (promptOption) {
      select.value = "";
    } else if (select.options.length > 0) {
      select.selectedIndex = 0;
    }

    select.dispatchEvent(
      new CustomEvent("options-changed", {
        bubbles: true,
      })
    );
  }
}
