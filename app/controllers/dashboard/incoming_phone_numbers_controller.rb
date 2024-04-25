module Dashboard
  class IncomingPhoneNumbersController < DashboardController
    def index
      @filtered_resources = apply_filters(scope.includes(:account))
      @resources = paginate_resources(@filtered_resources)
    end

    def show
      @resource = record
    end

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
        :voice_url, :voice_method, :status_callback_url, :status_callback_method, :sip_domain,
        :sms_url, :sms_method, :messaging_service_id
      )
    end

    def scope
      parent_scope.active_incoming_phone_numbers
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
