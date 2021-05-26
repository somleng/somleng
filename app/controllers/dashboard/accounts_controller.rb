module Dashboard
  class AccountsController < DashboardController
    skip_before_action :authorize_user!, only: :destroy

    def index
      @resources = apply_filters(accounts_scope)
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = accounts_scope.find(params[:id])
    end

    def new
      @resource = AccountForm.new(carrier: carrier)
    end

    def create
      @resource = AccountForm.new(permitted_params)
      @resource.carrier = carrier
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
      authorize(account)
      account.destroy
      respond_with(:dashboard, account)
    end

    private

    def permitted_params
      params.require(:account).permit(:name, :enabled)
    end

    def accounts_scope
      carrier.accounts
    end
  end
end
