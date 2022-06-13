module Dashboard
  class HomeController < DashboardController
    def show
      if current_user.carrier_user?
        redirect_to(dashboard_carrier_settings_path, status: :see_other)
      else
        redirect_to(dashboard_account_settings_path, status: :see_other)
      end
    end
  end
end
