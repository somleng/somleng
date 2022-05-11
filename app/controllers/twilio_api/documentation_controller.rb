module TwilioAPI
  class DocumentationController < ApplicationController
    def show
      custom_domain = CustomDomain.verified.find_by(host: request.hostname, type: :api)
      content = File.read(Rails.root.join("public/docs/twilio_api/index.html"))
      renderer = DocumentationRenderer.new(custom_domain:, content:)

      render(html: renderer.render)
    end
  end
end
