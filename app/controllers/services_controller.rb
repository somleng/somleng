class ServicesController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with(
    name: Rails.configuration.app_settings.fetch(:services_user),
    password: Rails.configuration.app_settings.fetch(:services_password)
  )

  private

  def respond_with_resource(resource, options = {})
    respond_with(:services, resource, **options)
  end
end
