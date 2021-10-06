import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "content", "revealButton" ]
  static values = { rawContent: String }

  reveal() {
    this.contentTarget.innerHTML = this.rawContentValue
    this.revealButtonTarget.style.display = "none"
  }
}
