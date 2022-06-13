module Dashboard
  class AccountSessionsController < DashboardController
    def create
      account_membership = account_memberships_scope.find(permitted_params[:id])
      current_user.update!(current_account_membership: account_membership)
      session[:current_account_membership] = account_membership.id
      redirect_to(dashboard_root_path, status: :see_other)
    end

    private

    def account_memberships_scope
      current_user.account_memberships
    end

    def permitted_params
      params.require(:account_membership).permit(:id)
    end
  end
end
