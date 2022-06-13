import { Controller } from "@hotwired/stimulus"
import Choices from "choices.js";

export default class extends Controller {
  static targets = [ "switcher", "badge" ]

  connect() {
    [].slice.call(this.element.querySelectorAll('[data-behavior~=choices-input]')).map(function (element) {
      return new Choices(element);
    });

    this.toggle()
  }

  toggle() {
    this.badgeTarget.innerHTML = this.switcherTargets.filter(e => e.checked).length
  }
}
