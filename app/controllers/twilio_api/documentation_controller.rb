module TwilioAPI
  class DocumentationController < ApplicationController
    skip_before_action :verify_custom_domain!

    def show
      unless app_request.custom_domain_request?
        return redirect_to("https://www.somleng.org/docs.html", allow_other_host: true)
      end

      custom_domain = app_request.find_custom_domain!(:api)
      renderer = DocumentationRenderer.new(
        custom_domain:,
        template: Rails.root.join("public/docs/twilio_api/index.html")
      )
      render(inline: renderer.render)
    end
  end
end
