module Dashboard
  class UserInvitationsController < Devise::InvitationsController
    layout "dashboard"

    private

    def invite_resource
      UserForm.new(permitted_params).invite!(current_inviter)
    end

    def permitted_params
      params.require(:user).permit(:name, :email, :carrier_role, :id)
    end

    def after_invite_path_for(_inviter, invitee)
      dashboard_user_path(invitee)
    end
  end
end
