module Dashboard
  class CarrierSettingsController < DashboardController
    def show
      @resource = current_carrier
    end

    def edit
      @resource = CarrierSettingsForm.initialize_with(current_carrier)
    end

    def update
      @resource = CarrierSettingsForm.new(permitted_params)
      @resource.carrier = current_carrier
      @resource.save

      respond_with(@resource, location: dashboard_carrier_settings_path)
    end

    private

    def permitted_params
      params.require(:carrier_settings).permit(
        :name, :country, :logo, :webhook_url, :enable_webhooks,
        :custom_dashboard_host, :custom_api_host
      )
    end

    def policy_class
      CarrierSettingsPolicy
    end

    def record
      @record ||= current_carrier
    end
  end
end
