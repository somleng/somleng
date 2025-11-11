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
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def edit
      @resource = AccountForm.initialize_with(record)
    end

    def update
      @resource = AccountForm.initialize_with(record)
      @resource.attributes = permitted_params
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
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
        tariff_plan_line_items: [ :id, :tariff_plan_id, :category ]
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
