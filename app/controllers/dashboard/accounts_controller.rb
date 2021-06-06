module Dashboard
  class AccountsController < DashboardController
    def index
      @resources = apply_filters(accounts_scope)
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(form_params.permit(:name, :outbound_sip_trunk_id, :enabled))
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def edit
      @resource = AccountForm.initialize_with(record)
    end

    def update
      @resource = initialize_form(form_params.permit(:outbound_sip_trunk_id, :enabled))
      @resource.account = record
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    private

    def initialize_form(params = {})
      @resource = AccountForm.new(params)
      @resource.carrier = current_carrier
      @resource
    end

    def form_params
      params.require(:account)
    end

    def accounts_scope
      current_carrier.accounts
    end

    def record
      @record ||= accounts_scope.find(params[:id])
    end
  end
end
