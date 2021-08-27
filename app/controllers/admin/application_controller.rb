module Admin
  class ApplicationController < Administrate::ApplicationController
    http_basic_authenticate_with(
      name: Rails.configuration.app_settings.fetch(:admin_username),
      password: Rails.configuration.app_settings.fetch(:admin_password)
    )
  end
end
