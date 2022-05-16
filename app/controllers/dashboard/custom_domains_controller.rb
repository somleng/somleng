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
      mail_custom_domain = current_carrier.custom_domain(:mail)
      current_carrier.custom_domains.destroy_all
      ExecuteWorkflowJob.perform_later(DeleteEmailIdentity.to_s, mail_custom_domain.host)

      respond_with(CustomDomain.new, location: edit_dashboard_carrier_settings_custom_domain_path)
    end

    def verify
      unverified_domains = current_carrier.custom_domains.unverified.map { |domain| CustomDomain.wrap(domain) }
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

    def regenerate
      @resource = CustomDomainForm.initialize_with(current_carrier)
      @resource.regenerate_mail_domain_identity

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
