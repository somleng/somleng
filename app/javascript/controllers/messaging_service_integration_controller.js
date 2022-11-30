import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "incomingMessageBehaviorInput", "inboundRequestSection"]

  connect() {
    this.changeIncomingMessageBehavior();
  }

  changeIncomingMessageBehavior() {
    const element = this.incomingMessageBehaviorInputTargets.find((element) => element.checked)

    if (element.value === "webhook") {
      this.inboundRequestSectionTarget.style.display = "flex";
    } else {
      this.inboundRequestSectionTarget.style.display = "none";
    }
  }
}
