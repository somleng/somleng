import { Controller } from "stimulus"
import $ from "jquery"
import "bootstrap/js/dist/util"
import "bootstrap/js/dist/collapse"

export default class extends Controller {
  static targets = [ "switcher", "fieldInputsContainer" ]

  connect() {
    this.toggle()
  }

  toggle() {
    $(this.fieldInputsContainerTarget).collapse(this.enabled ? "show" : "hide")
    this.fieldInputsContainerTarget.querySelectorAll("input, select, textarea").forEach((element) => {
      element.disabled = !this.enabled
    })
  }

  get enabled() {
    return this.switcherTarget.checked
  }
}
