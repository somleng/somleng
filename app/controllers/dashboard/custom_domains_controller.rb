module Dashboard
  class CustomDomainsController < DashboardController
    def edit
      @resource = CustomDomainForm.initialize_with(current_carrier)
    end

    def update
      @resource = CustomDomainForm.new(permitted_params)
      @resource.carrier = current_carrier
      @resource.save

      respond_with(@resource, location: edit_dashboard_carrier_settings_custom_domain_path)
    end

    def destroy
      current_carrier.custom_domains.destroy_all
      respond_with(CustomDomain.new, location: edit_dashboard_carrier_settings_custom_domain_path)
    end

    def verify
      unverified_domains = current_carrier.custom_domains.unverified
      verified = unverified_domains.all?(&:verify!)

      if verified
        flash[:notice] = "All domains were verified successfully."
      else
        flash[:alert] = "Not all domains were verified successfully. Please check your DNS settings and try again later."
      end

      respond_with(
        @resource,
        location: edit_dashboard_carrier_settings_custom_domain_path
      )
    end

    private

    def permitted_params
      params.require(:custom_domain).permit(:dashboard_host, :api_host, :mail_host)
    end

    def policy_class
      CustomDomainPolicy
    end

    def record
      @record ||= current_carrier
    end
  end
end
