module Dashboard
  class PhoneNumberConfigurationsController < DashboardController
    def edit
      @resource = PhoneNumberConfigurationForm.initialize_with(record)
    end

    def update
      @resource = PhoneNumberConfigurationForm.new(permitted_params)
      @resource.phone_number_configuration = record
      @resource.save

      respond_with(:dashboard, @resource, location: edit_dashboard_phone_number_configuration_path(@resource.phone_number))
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
      @record ||= begin
        phone_number = phone_numbers_scope.find(params[:phone_number_id])
        phone_number.configuration || phone_number.build_configuration
      end
    end
  end
end
