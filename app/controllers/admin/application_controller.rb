module Admin
  class ApplicationController < Administrate::ApplicationController
    helper ApplicationHelper

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

    def paginate_resources(resources)
      super.without_count
    end
  end
end
