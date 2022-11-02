import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "smsGatewayInput", "slotIndexInput", "channelGroupInput" ]

  connect() {
    this.changeSMSGateway();
  }

  changeSMSGateway() {
    const smsGatewayAttributes = JSON.parse(this.smsGatewayInputTarget.dataset.smsGatewayAttributes || '{}')
    const selectedSMSGateway = this.smsGatewayInputTarget.selectedOptions[0];
    if (selectedSMSGateway.value) {
      const attributes = smsGatewayAttributes[selectedSMSGateway.value];
      this.slotIndexInputTarget.value = attributes.next_available_slot_index;
    }
    else {
      const defaultSlotIndexValue = this.slotIndexInputTarget.dataset.defaultValue;
      this.slotIndexInputTarget.value = defaultSlotIndexValue ? defaultSlotIndexValue : "";
    }
  }
}
