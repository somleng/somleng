module Dashboard
  class IncomingPhoneNumbersController < DashboardController
    def index
      @resources = paginate_resources(apply_filters(scope))
    end

    def show
      @resource = record
    end

    def edit
      @resource = IncomingPhoneNumberForm.initialize_with(record)
    end

    def update
      @resource = IncomingPhoneNumberForm.new(permitted_params)
      @resource.incoming_phone_number = record
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.release!
      respond_with(:dashboard, record, location: dashboard_incoming_phone_numbers_path)
    end

    private

    def permitted_params
      params.require(:incoming_phone_number).permit(
        :friendly_name,
        :voice_url, :voice_method, :status_callback_url, :status_callback_method, :sip_domain,
        :sms_url, :sms_method, :messaging_service_id
      )
    end

    def scope
      parent_scope.incoming_phone_numbers
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
