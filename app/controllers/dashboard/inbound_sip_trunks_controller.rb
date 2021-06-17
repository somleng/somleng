module Dashboard
  class InboundSIPTrunksController < DashboardController
    def index
      @resources = apply_filters(inbound_sip_trunks_scope)
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
      @resource = InboundSIPTrunkForm.initialize_with(record)
    end

    def update
      @resource = initialize_form(permitted_params)
      @resource.inbound_sip_trunk = record
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    private

    def permitted_params
      params.require(:inbound_sip_trunk).permit(:name, :source_ip)
    end

    def initialize_form(params = {})
      form = InboundSIPTrunkForm.new(params)
      form.carrier = current_carrier
      form
    end

    def inbound_sip_trunks_scope
      current_carrier.inbound_sip_trunks
    end

    def record
      @record ||= inbound_sip_trunks_scope.find(params[:id])
    end
  end
end
