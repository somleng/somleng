module Dashboard
  class UserInvitationsController < DashboardController
    def update
      record.invite!(current_user)
      redirect_back(
        fallback_location: dashboard_root_url,
        notice: "An invitation email has been sent to #{record.email}."
      )
    end

    private

    def record
      @record ||= find_user
    end

    def find_user
      if current_organization.carrier?
        find_carrier_account_user || find_carrier_user!
      elsif current_organization.account?
        find_account_user!
      end
    end

    def find_carrier_account_user
      current_carrier.account_users.find_by(id: params[:id])
    end

    def find_carrier_user!
      current_carrier.users.find(params[:id])
    end

    def find_account_user!
      current_account.users.find(params[:id])
    end
  end
end
