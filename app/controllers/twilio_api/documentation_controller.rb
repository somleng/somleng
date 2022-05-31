module TwilioAPI
  class DocumentationController < ApplicationController
    def show
      renderer = DocumentationRenderer.new(
        carrier: app_request.find_carrier!,
        template: Rails.root.join("public/docs/twilio_api/index.html")
      )
      render(inline: renderer.render)
    end
  end
end
