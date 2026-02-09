module Dashboard
  class BalanceTransactionsController < DashboardController
    def index
      @resources = apply_filters(scope)
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = BalanceTransactionForm.new(carrier: current_carrier)
    end

    def create
      @resource = BalanceTransactionForm.new(
        carrier: current_carrier,
        created_by: current_user,
        **permitted_params
      )
      UpdateAccountBalanceForm.call(@resource)
      respond_with(:dashboard, @resource)
    end

    def show
      @resource = record
    end

    def edit
      @resource = BalanceTransactionForm.initialize_with(record)
    end

    def update
      @resource = BalanceTransactionForm.initialize_with(record)
      permitted_params = params.require(:balance_transaction).permit(:description)
      @resource.attributes = permitted_params
      @resource.save
      respond_with(:dashboard, @resource)
    end

    private

    def scope
      parent_scope.balance_transactions
    end

    def permitted_params
      params.require(:balance_transaction).permit(
        :account_id,
        :type,
        :amount,
        :description
      )
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
