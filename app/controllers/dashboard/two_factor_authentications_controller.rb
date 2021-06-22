module Dashboard
  class TwoFactorAuthenticationsController < DashboardController
    skip_before_action :enforce_two_factor_authentication!

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

    def destroy
      record.update!(otp_required_for_login: false)
      redirect_back(fallback_location: dashboard_root_path, notice: "2FA was successfully reset for #{record.email}.")
    end

    private

    def permitted_params
      params.require(:two_factor_authentication).permit(:otp_attempt)
    end

    def record
      @record ||= User.find(params[:id])
    end
  end
end
