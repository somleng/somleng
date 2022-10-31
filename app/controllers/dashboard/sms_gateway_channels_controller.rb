module Dashboard
  class SMSGatewayChannelsController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:sms_gateway, :channel_group, :phone_number))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = initialize_form
    end

    def create
      permitted_params = required_params.permit(
        :name, :slot_index, :sms_gateway_id, :phone_number_id, :route_prefixes
      )
      @resource = initialize_form(permitted_params)
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def show
      @resource = record
    end

    def edit
      @resource = SMSGatewayChannelForm.initialize_with(record)
    end

    def update
      permitted_params = required_params.permit(
        :name, :slot_index, :channel_group_id, :phone_number_id, :route_prefixes
      )
      @resource = initialize_form(permitted_params)
      @resource.sms_gateway_channel = record
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    private

    def initialize_form(params = {})
      form = SMSGatewayChannelForm.new(params)
      form.carrier = current_carrier
      form
    end

    def required_params
      params.require(:sms_gateway_channel)
    end

    def scope
      current_carrier.sms_gateway_channels
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
