module Dashboard
  class CustomDomainsController < DashboardController
    def show
      @resource = current_carrier
    end

    def edit
      @resource = CustomDomainForm.initialize_with(current_carrier)
    end

    def update
      @resource = CustomDomainForm.new(permitted_params)
      @resource.carrier = current_carrier
      @resource.save

      respond_with(@resource, location: dashboard_carrier_settings_path)
    end

    private

    def permitted_params
      params.require(:custom_domain).permit(:dashboard_host, :api_host)
    end

    def policy_class
      CustomDomainPolicy
    end
  end
end
