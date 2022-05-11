module TwilioAPI
  class DocumentationController < ApplicationController
    def show
      unless custom_domain_request?
        return redirect_to("https://www.somleng.org/docs.html", allow_other_host: true)
      end

      custom_domain = CustomDomain.verified.find_by(host: request.hostname, type: :api)

      if custom_domain.blank?
        head(:not_found)
      else
        renderer = DocumentationRenderer.new(
          custom_domain:,
          template: Rails.root.join("public/docs/twilio_api/index.html")
        )

        render(inline: renderer.render)
      end
    end

    def custom_domain_request?
      request.hostname != URI(Rails.configuration.app_settings.fetch(:api_url_host)).host
    end
  end
end
