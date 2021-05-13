module Dashboard
  class AccountsController < DashboardController
    def index
      @resources = apply_filters(accounts_scope.includes(:cardholder, :cards))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = accounts_scope.find(params[:id])
    end

    def new
      @resource = AccountForm.new(card_issuer: card_issuer)
    end

    def create
      @resource = AccountForm.new(permitted_params)
      @resource.card_issuer = card_issuer
      @resource.save

      respond_with(:dashboard, @resource)
    end

    private

    def permitted_params
      params.require(:account).permit(
        :cardholder_id, :number
      )
    end

    def accounts_scope
      card_issuer.accounts
    end
  end
end
