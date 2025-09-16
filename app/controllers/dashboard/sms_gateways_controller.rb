module Dashboard
  class SMSGatewaysController < DashboardController
    def index
      @resources = apply_filters(sms_gateways_scope.includes(:channel_groups, :channels))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(permitted_params)
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def show
      @resource = record
    end

    def edit
      @resource = SMSGatewayForm.initialize_with(record)
    end

    def update
      @resource = initialize_form(permitted_params)
      @resource.sms_gateway = record
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    private

    def initialize_form(params = {})
      form = SMSGatewayForm.new(params)
      form.carrier = current_carrier
      form
    end

    def permitted_params
      params.require(:sms_gateway).permit(:name, :max_channels, :default_sender, :device_type)
    end

    def sms_gateways_scope
      current_carrier.sms_gateways
    end

    def record
      @record ||= sms_gateways_scope.find(params[:id])
    end
  end
end
