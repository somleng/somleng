module Admin
  class ApplicationController < Administrate::ApplicationController
    include AdministrateExportable::Exporter

    http_basic_authenticate_with(
      name: Rails.configuration.app_settings.fetch(:admin_username),
      password: Rails.configuration.app_settings.fetch(:admin_password)
    )

    private

    def default_sorting_attribute
      :sequence_number
    end

    def default_sorting_direction
      :desc
    end
  end
end
