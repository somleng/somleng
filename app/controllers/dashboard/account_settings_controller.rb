module Dashboard
  class AccountSettingsController < DashboardController
    def show
      @resource = current_account
    end

    def edit
      @resource = AccountSettingsForm.initialize_with(current_account)
    end

    def update
      @resource = AccountSettingsForm.new(permitted_params)
      @resource.account = current_account
      @resource.save

      respond_with(@resource, location: dashboard_account_settings_path)
    end

    private

    def permitted_params
      params.require(:account_settings).permit(:name)
    end

    def policy_class
      AccountSettingsPolicy
    end
  end
end
