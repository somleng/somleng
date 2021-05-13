module Dashboard
  class TwoFactorAuthenticationsController < DashboardController
    skip_before_action :enforce_two_factor_authentication!
    skip_before_action :authorize_user!
    skip_after_action :verify_authorized

    def new
      @resource = TwoFactorAuthenticationForm.new
    end

    def create
      @resource = TwoFactorAuthenticationForm.new(permitted_params)
      @resource.user = current_user
      @resource.save

      respond_with(
        @resource,
        notice: "2FA was successfully enabled.",
        location: -> { after_sign_in_path_for(current_user) }
      )
    end

    private

    def permitted_params
      params.require(:two_factor_authentication).permit(:otp_attempt)
    end
  end
end
