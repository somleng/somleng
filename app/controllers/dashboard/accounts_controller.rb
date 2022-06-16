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
      @resource = initialize_form(permitted_params)
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def edit
      @resource = AccountForm.initialize_with(record)
    end

    def update
      @resource = initialize_form(permitted_params)
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
      @resource.current_user = current_user
      @resource
    end

    def permitted_params
      params.require(:account).permit(
        :name,
        :owner_name,
        :owner_email,
        :outbound_sip_trunk_id,
        :calls_per_second,
        :enabled
      )
    end

    def accounts_scope
      current_carrier.accounts
    end

    def record
      @record ||= accounts_scope.find(params[:id])
    end
  end
end
