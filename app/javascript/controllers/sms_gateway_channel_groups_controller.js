import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "smsGatewayInput", "channelsInput"]

  connect() {}

  changeSMSGateway(event) {
    const maxChannels = event.detail.customProperties["maxChannels"];
    if (maxChannels) {
      console.log(maxChannels);
      // this doesn't work
      // this.channelsInputTarget.setChoices([{ value: "1", label: "Foobar"}], 'value', 'label', true);
    } else {
      // this.channelInputTarget.disable();
    }
  }
}
