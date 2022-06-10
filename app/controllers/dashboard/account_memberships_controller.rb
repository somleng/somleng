module Dashboard
  class AccountMembershipsController < DashboardController
    def index
      @resources = apply_filters(account_memberships_scope.includes(:user))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(form_params.permit(:name, :email, :role))
      @resource.save

      respond_with(
        :dashboard,
        @resource,
        notice: "An invitation email has been sent to #{@resource.email}."
      )
    end

    def edit
      @resource = AccountMembershipForm.initialize_with(record)
    end

    def update
      @resource = initialize_form(form_params.permit(:role))
      @resource.account_membership = record
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    private

    def initialize_form(params = {})
      form = AccountMembershipForm.new(params)
      form.account = current_account
      form.current_user = current_user
      form
    end

    def account_memberships_scope
      current_account.account_memberships
    end

    def form_params
      params.require(:account_membership)
    end

    def record
      @record ||= account_memberships_scope.find(params[:id])
    end
  end
end
