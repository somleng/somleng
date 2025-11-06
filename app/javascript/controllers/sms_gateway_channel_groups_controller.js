import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["smsGatewayInput", "channelsInput"];
  static values = {
    collection: Array,
  };

  changeSMSGateway(event) {
    if (this.smsGatewayInputTarget.disabled) {
      return;
    }

    this.channelsInputChoices.clearStore();
    const selectedSMSGateway = this.collectionValue.find(
      (smsGateway) => smsGateway[1] == event.target.value
    );
    if (selectedSMSGateway) {
      const availableChannels = selectedSMSGateway[2].data.available_channels;
      const choices = availableChannels.map((channel) => ({
        value: channel.toString(),
        label: channel.toString(),
      }));
      this.channelsInputChoices.setChoices(choices, "value", "label", true);
    }
  }
}
