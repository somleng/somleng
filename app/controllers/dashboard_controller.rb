class DashboardController < ApplicationController
  include Pundit

  self.responder = DashboardResponder
  respond_to :html

  helper_method :current_carrier
  helper_method :current_organization
  helper_method :current_account

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

  def current_organization
    current_account_or_carrier = current_account_membership&.account || current_carrier

    return BlankOrganization.new if current_account_or_carrier.blank?

    @current_organization ||= Organization.new(current_account_or_carrier)
  end

  def current_account
    current_account_membership.account
  end

  def current_carrier
    current_user.carrier
  end

  def current_account_membership
    session[:current_account_membership] ||= current_user.current_account_membership_id
    account_membership = current_user.account_memberships.find_by(id: session[:current_account_membership])

    return account_membership if account_membership.present?

    BlankAccountMembership.new
  end

  def pundit_user
    UserContext.new(current_user, current_organization, current_account_membership)
  end

  class Organization < SimpleDelegator
    def carrier?
      __getobj__.is_a?(Carrier)
    end

    def account?
      __getobj__.is_a?(Account)
    end
  end

  class BlankOrganization
    def carrier?
      false
    end

    def name
      "Select Account"
    end

    def account_memberships
      AccountMembership.none
    end
  end

  class BlankAccountMembership
    def owner?
      false
    end

    def account; end

    def user; end
  end
end
