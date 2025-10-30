class DashboardController < ApplicationController
  self.responder = DashboardResponder
  respond_to :html

  include UserAuthorization

  prepend_before_action :authenticate_user!
  before_action :enforce_two_factor_authentication!
  helper_method :filter_params

  private

  def enforce_two_factor_authentication!
    return if current_user.otp_required_for_login?

    redirect_to(
      new_dashboard_two_factor_authentication_path,
      alert: "Two Factor Authentication Required",
      status: :see_other
    )
  end

  def apply_filters(resources_scope)
    filter_class(resources_scope).new(
      resources_scope:,
      input_params: request.query_parameters
    ).apply
  end

  def paginate_resources(resources_scope)
    resources_scope.latest_first.page(params[:page]).without_count
  end

  def filter_class(resources_scope)
    resources_scope.filter_class
  end

  def filter_params
    request.query_parameters.slice(:filter)
  end
end
