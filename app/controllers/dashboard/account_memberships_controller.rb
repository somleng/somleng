module Dashboard
  class AccountMembershipsController < DashboardController
    skip_before_action :authorize_user!, only: :destroy

    def index
      @resources = apply_filters(account_memberships_scope.includes(:user, :account))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = account_memberships_scope.find(params[:id])
    end

    def new
      @resource = AccountMembershipForm.new(carrier: current_carrier)
    end

    def create
      @resource = AccountMembershipForm.new(form_params.permit(:account_id, :name, :email, :role))
      @resource.carrier = current_carrier
      @resource.save

      respond_with(
        :dashboard,
        @resource,
        notice: "An invitation email has been sent to #{@resource.email}."
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

      respond_with(@resource)
    end

    def destroy
      @resource = account_memberships_scope.find(params[:id])
      authorize(@resource)
      @resource.destroy
      respond_with(@resource)
    end

    private

    def account_memberships_scope
      current_organization.account_memberships
    end

    def form_params
      params.require(:account_membership)
    end
  end
end
