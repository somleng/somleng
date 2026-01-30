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
      @resource = AccountForm.new(carrier: current_carrier, current_user:)
    end

    def create
      @resource = AccountForm.new(carrier: current_carrier, current_user:, **permitted_params)
      UpdateAccountForm.call(@resource)

      respond_with(:dashboard, @resource)
    end

    def edit
      @resource = AccountForm.initialize_with(record)
    end

    def update
      @resource = AccountForm.initialize_with(record)
      @resource.attributes = permitted_params
      UpdateAccountForm.call(@resource)

      respond_with(:dashboard, @resource)
    end

    def destroy
      DestroyAccount.call(record)
      respond_with(:dashboard, record)
    end

    private

    def permitted_params
      params.require(:account).permit(
        :name,
        :default_tts_voice,
        :owner_name,
        :owner_email,
        :sip_trunk_id,
        :calls_per_second,
        :enabled,
        :billing_enabled,
        :billing_mode,
        tariff_plan_subscriptions: [ :id, :plan_id, :category, :enabled ]
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
