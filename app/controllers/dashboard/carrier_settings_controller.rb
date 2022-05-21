module Dashboard
  class CarrierSettingsController < DashboardController
    self.raise_on_open_redirects = false

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

      respond_with(
        @resource,
        location: dashboard_carrier_settings_url(subdomain: current_carrier.subdomain)
      )
    end

    private

    def permitted_params
      params.require(:carrier_settings).permit(
        :name, :country, :logo, :webhook_url, :enable_webhooks, :website, :subdomain
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
