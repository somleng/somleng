class DashboardController < ApplicationController
  include Pundit

  self.responder = DashboardResponder
  respond_to :html

  delegate :carrier, to: :current_user
  helper_method :carrier

  before_action :authenticate_user!
  before_action :enforce_two_factor_authentication!

  before_action :authorize_user!
  after_action :verify_authorized
  rescue_from Pundit::NotAuthorizedError do
    redirect_to dashboard_root_path, alert: "You are not authorized to perform this action"
  end

  private

  def enforce_two_factor_authentication!
    return if current_user.otp_required_for_login?

    redirect_to(
      new_dashboard_two_factor_authentication_path,
      alert: "Two Factor Authentication Required"
    )
  end

  def authorize_user!
    authorize(current_user, policy_class: policy_class)
  end

  def policy_class
    "#{controller_name.classify}Policy".constantize
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
