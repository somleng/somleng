module Dashboard
  class SIPTrunksController < DashboardController
    def index
      @resources = apply_filters(sip_trunks_scope)
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(permitted_params)
      CreateSIPTrunk.call(@resource.sip_trunk) if @resource.save

      respond_with(:dashboard, @resource)
    end

    def show
      @resource = record
    end

    def edit
      @resource = SIPTrunkForm.initialize_with(record)
    end

    def update
      @resource = initialize_form(permitted_params)
      @resource.sip_trunk = record
      UpdateSIPTrunk.call(record) if @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      DeleteSIPTrunk.call(record) if record.destroy
      respond_with(:dashboard, record)
    end

    private

    def initialize_form(params = {})
      form = SIPTrunkForm.new(params)
      form.carrier = current_carrier
      form
    end

    def permitted_params
      params.require(:sip_trunk).permit(
        :authentication_mode, :name, :region, :max_channels,
        :source_ip, :country,
        :host, :dial_string_prefix, :national_dialing,
        :plus_prefix, :route_prefixes, :default_sender
      )
    end

    def sip_trunks_scope
      current_carrier.sip_trunks
    end

    def record
      @record ||= sip_trunks_scope.find(params[:id])
    end
  end
end
