import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "localePreviewInput", "messagePreviewContent" ]

  connect() {
    this.updateLocalePreview();
  }

  updateLocalePreview() {
    const messagePreviews = JSON.parse(this.localePreviewInputTarget.dataset.messagePreviews)
    const messagePreview = messagePreviews[this.localePreviewInputTarget.value]
    this.messagePreviewContentTarget.textContent = messagePreview
  }
}
