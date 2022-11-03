module Dashboard
  class SMSGatewayChannelGroupsController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:sms_gateway, :channels))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = initialize_form
    end

    def create
      permitted_params = required_params.permit(:name, :sms_gateway_id, :route_prefixes, channels: [])
      @resource = initialize_form(permitted_params)
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def show
      @resource = record
    end

    def edit
      @resource = SMSGatewayChannelGroupForm.initialize_with(record)
    end

    def update
      permitted_params = required_params.permit(:name, :route_prefixes, channels: [])
      @resource = initialize_form(permitted_params)
      @resource.channel_group = record
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    private

    def initialize_form(params = {})
      form = SMSGatewayChannelGroupForm.new(params)
      form.carrier = current_carrier
      form
    end

    def required_params
      params.require(:sms_gateway_channel_group)
    end

    def scope
      current_carrier.sms_gateway_channel_groups
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
