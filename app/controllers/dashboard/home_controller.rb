module Dashboard
  class HomeController < DashboardController
    def show
      if current_organization.account?
        redirect_to(dashboard_account_settings_path)
      elsif current_organization.carrier?
        redirect_to(dashboard_carrier_settings_path)
      end
    end
  end
end
