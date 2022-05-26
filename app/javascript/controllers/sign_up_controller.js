import urlSlug from 'url-slug'

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "companyInput", "subdomainInput" ]

  updateCompanyInput() {
    this.subdomainInputTarget.value = urlSlug(this.companyInputTarget.value)
  }
}
