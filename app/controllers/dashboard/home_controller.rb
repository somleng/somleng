module Dashboard
  class HomeController < DashboardController
    def show
      if current_organization.account?
        redirect_to(dashboard_account_settings_path)
      else
        redirect_to(dashboard_carrier_settings_path)
      end
    end
  end
end
