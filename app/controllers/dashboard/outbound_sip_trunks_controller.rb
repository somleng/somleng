module Dashboard
  class OutboundSIPTrunksController < DashboardController
    def index
      @resources = apply_filters(outbound_sip_trunks_scope)
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
      @resource = OutboundSIPTrunkForm.initialize_with(record)
    end

    def update
      @resource = initialize_form(permitted_params)
      @resource.outbound_sip_trunk = record
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    private

    def initialize_form(params = {})
      form = OutboundSIPTrunkForm.new(params)
      form.carrier = current_carrier
      form
    end

    def permitted_params
      params.require(:outbound_sip_trunk).permit(
        :name, :host, :dial_string_prefix, :trunk_prefix, :plus_prefix
      )
    end

    def outbound_sip_trunks_scope
      current_carrier.outbound_sip_trunks
    end

    def record
      @record ||= outbound_sip_trunks_scope.find(params[:id])
    end
  end
end
