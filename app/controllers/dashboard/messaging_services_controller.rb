module Dashboard
  class MessagingServicesController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:account, :phone_numbers))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    def edit
      @resource = MessagingServiceForm.initialize_with(record)
    end

    def update
      permitted_params = required_params.permit(
        :name,
        :inbound_request_url,
        :inbound_request_method,
        :status_callback_url,
        :smart_encoding,
        :inbound_message_behavior,
        phone_number_ids: []
      )
      @resource = initialize_form(permitted_params)
      @resource.account = record.account
      @resource.messaging_service = record
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(required_params.permit(:name, :account_id))
      @resource.save

      respond_with(
        :dashboard,
        @resource,
        location: -> { edit_dashboard_messaging_service_path(@resource.messaging_service) }
      )
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    private

    def initialize_form(params = {})
      form = MessagingServiceForm.new(params)
      form.carrier = current_carrier
      form.account = current_account unless current_user.carrier_user?
      form
    end

    def required_params
      params.require(:messaging_service)
    end

    def scope
      parent_scope.messaging_services
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
