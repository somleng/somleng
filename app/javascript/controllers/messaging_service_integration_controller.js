import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "InboundMessageBehaviorInput", "inboundRequestSection"]

  connect() {
    this.changeInboundMessageBehavior();
  }

  changeInboundMessageBehavior() {
    const element = this.InboundMessageBehaviorInputTargets.find((element) => element.checked)

    if (element.value === "webhook") {
      this.inboundRequestSectionTarget.style.display = "flex";
    } else {
      this.inboundRequestSectionTarget.style.display = "none";
    }
  }
}
