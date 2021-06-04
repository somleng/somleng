import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "content", "revealButton" ]

  reveal() {
    this.contentTarget.innerHTML = this.data.get("rawContent")
    this.revealButtonTarget.style.display = "none"
  }
}
