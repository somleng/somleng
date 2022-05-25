module TwilioAPI
  class DocumentationController < ApplicationController
    def show
      carrier = Carrier.find_by!(subdomain: request.subdomains.first)
      renderer = DocumentationRenderer.new(
        carrier:,
        template: Rails.root.join("public/docs/twilio_api/index.html")
      )
      render(inline: renderer.render)
    end
  end
end
