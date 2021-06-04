module Dashboard
  class AccountSettingsController < DashboardController
    def show
      @resource = current_account
    end

    private

    def policy_class
      AccountSettingsPolicy
    end
  end
end
