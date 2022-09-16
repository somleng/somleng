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
      @resource.save

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
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
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
        :name, :source_ip, :trunk_prefix_replacement,
        :host, :dial_string_prefix, :trunk_prefix, :plus_prefix
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
