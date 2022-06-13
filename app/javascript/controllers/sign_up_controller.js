import { Controller } from "@hotwired/stimulus"
import urlSlug from 'url-slug'

export default class extends Controller {
  static targets = [ "companyInput", "subdomainInput" ]

  updateCompanyInput() {
    this.subdomainInputTarget.value = urlSlug(this.companyInputTarget.value)
  }
}
