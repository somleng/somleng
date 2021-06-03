module Dashboard
  class AccountsController < DashboardController
    def index
      @resources = apply_filters(accounts_scope)
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = accounts_scope.find(params[:id])
    end

    def new
      @resource = AccountForm.new(carrier: current_carrier)
    end

    def create
      @resource = AccountForm.new(permitted_params)
      @resource.carrier = current_carrier
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def edit
      account = accounts_scope.find(params[:id])
      @resource = AccountForm.initialize_with(account)
    end

    def update
      account = accounts_scope.find(params[:id])
      @resource = AccountForm.new(permitted_params)
      @resource.account = account
      @resource.carrier = account.carrier
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      account = accounts_scope.find(params[:id])
      account.destroy
      respond_with(:dashboard, account)
    end

    private

    def permitted_params
      params.require(:account).permit(:name, :enabled)
    end

    def accounts_scope
      current_carrier.accounts
    end
  end
end
