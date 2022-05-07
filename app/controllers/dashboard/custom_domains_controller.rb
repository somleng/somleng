module Dashboard
  class CustomDomainsController < DashboardController
    def show
      @custom_domains = current_carrier.custom_domains

      raise ActiveRecord::RecordNotFound if @custom_domains.blank?
    end

    def edit
      @resource = CustomDomainForm.initialize_with(current_carrier)
    end

    def update
      @resource = CustomDomainForm.new(permitted_params)
      @resource.carrier = current_carrier
      @resource.save

      respond_with(@resource, location: dashboard_carrier_settings_custom_domain_path)
    end

    def destroy
      current_carrier.custom_domains.destroy_all
      respond_with(CustomDomain.new, location: dashboard_carrier_settings_path)
    end

    def verify
      current_carrier.custom_domains.where(verified_at: nil).each do |custom_domain|
        VerifyCustomDomainJob.perform_later(custom_domain, reverify: false)
      end

      respond_with(
        @resource,
        location: dashboard_carrier_settings_custom_domain_path,
        notice: "Manual domain verification enqueued."
      )
    end

    private

    def permitted_params
      params.require(:custom_domain).permit(:dashboard_host, :api_host)
    end

    def policy_class
      CustomDomainPolicy
    end

    def record
      @record ||= current_carrier
    end
  end
end
