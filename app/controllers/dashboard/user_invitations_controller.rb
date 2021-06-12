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
      @record ||= User.find(params[:id])
    end
  end
end
