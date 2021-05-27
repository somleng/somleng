module Dashboard
  class AccountMembershipsController < DashboardController
    def index
      @resources = apply_filters(account_memberships_scope.includes(:user))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = account_memberships_scope.find(params[:id])
    end

    def new
      @resource = AccountMembershipForm.new(account: account)
    end

    def create
      @resource = AccountMembershipForm.new(form_params.permit(:name, :email, :role))
      @resource.account = account
      @resource.save

      respond_with(
        @resource,
        notice: "An invitation email has been sent to #{@resource.email}.",
        location: dashboard_account_membership_path(@account, @resource)
      )
    end

    def edit
      account_membership = account_memberships_scope.find(params[:id])
      @resource = AccountMembershipForm.initialize_with(account_membership)
    end

    def update
      account_membership = account_memberships_scope.find(params[:id])
      @resource = AccountMembershipForm.new(form_params.permit(:role))
      @resource.account_membership = account_membership
      @resource.save

      respond_with(@resource, location: dashboard_account_membership_path(@account, @resource))
    end

    def destroy
      @resource = account_memberships_scope.find(params[:id])
      @resource.destroy
      respond_with(@resource, location: dashboard_account_memberships_path(@account))
    end

    private

    def account
      @account ||= carrier.accounts.find(params[:account_id])
    end

    def account_memberships_scope
      account.account_memberships
    end

    def form_params
      params.require(:account_membership)
    end
  end
end
