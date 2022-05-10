module TwilioAPI
  class DocumentationController < ApplicationController
    def show
      content = File.read(Rails.root.join("doc/twilio_api/index.html"))
      carrier = Carrier.from_domain(host: request.hostname, type: :api)

      return render(html: content.html_safe) if carrier.blank?

      if carrier.logo.present?
        html_doc = Nokogiri::HTML(content)
        logo = html_doc.at_css(".logo")
        logo[:src] = url_for(carrier.logo)
        logo[:alt] = carrier.name
      end

      content = html_doc.to_html
      content.gsub!("api.somleng.org", carrier.custom_domain(:api).host)
      content.gsub!(/somleng/i, carrier.name)

      render(html: content.html_safe)
    end
  end
end
