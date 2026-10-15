module Dashboard
  class AuthTokensController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:account))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    def destroy
      record.revoke
      respond_with(:dashboard, record)
    end

    def create
      permitted_params = params.require(:auth_token).permit(:account_id)
      account = current_user.carrier_user? ? current_carrier.accounts.carrier_managed.find(permitted_params[:account_id]) : current_account
      @resource = AuthToken.create!(account:)
      respond_with(:dashboard, @resource, location: -> { dashboard_auth_tokens_path(filter_params) })
    end

    def update
      permitted_params = params.require(:auth_token).permit(:primary)
      record.promote! if ActiveModel::Type::Boolean.new.cast(permitted_params[:primary])
      respond_with(:dashboard, record)
    end

    private

    def scope
      result = parent_scope.auth_tokens
      result = result.joins(:account).merge(Account.carrier_managed) if current_user.carrier_user?
      result
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
