module Dashboard
  class CarrierSettingsController < DashboardController
    self.action_on_open_redirect = :log

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
        location: dashboard_carrier_settings_url(host: current_carrier.subdomain_host)
      )
    end

    private

    def permitted_params
      params.require(:carrier_settings).permit(
        :name, :country, :billing_currency, :logo, :favicon, :webhook_url, :enable_webhooks, :website, :subdomain,
        :custom_app_host, :custom_api_host, :default_tariff_package_id
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
