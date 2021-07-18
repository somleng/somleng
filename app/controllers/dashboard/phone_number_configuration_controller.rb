module Dashboard
  class PhoneNumberConfigurationController < DashboardController
    def edit
      @resource = PhoneNumberConfigurationForm.initialize_with(record)
    end

    def update
      @resource = PhoneNumberConfigurationForm.new(permitted_params)
      @resource.phone_number = record
      @resource.save

      respond_with(:dashboard, @resource, location: dashboard_phone_number_path(@resource))
    end

    private

    def permitted_params
      params.require(:phone_number_configuration).permit(
        :voice_url, :voice_method, :status_callback_url, :status_callback_method, :sip_domain
      )
    end

    def phone_numbers_scope
      current_organization.phone_numbers
    end

    def record
      @record ||= phone_numbers_scope.find(params[:id])
    end
  end
end
