class DashboardController < ApplicationController
  self.responder = DashboardResponder
  respond_to :html

  before_action :authenticate_user!
  before_action :enforce_two_factor_authentication!

  private

  def enforce_two_factor_authentication!
    return if current_user.otp_required_for_login?

    redirect_to(
      new_dashboard_two_factor_authentication_path,
      alert: "Two Factor Authentication Required"
    )
  end

  def apply_filters(resources_scope)
    resources_scope.filter_class.new(
      resources_scope: resources_scope,
      input_params: request.params
    ).apply
  end

  def paginate_resources(resources_scope)
    resources_scope.latest_first.page(params[:page])
  end
end
