module UserAuthorization
  extend ActiveSupport::Concern
  include Pundit::Authorization
  include Devise::Controllers::SignInOut

  included do
    helper_method :current_carrier
    helper_method :current_account
    helper_method :current_account_membership

    before_action :select_account_membership!
    before_action :authorize_carrier!
    before_action :authorize_user!
    after_action :verify_authorized
    rescue_from Pundit::NotAuthorizedError do
      redirect_to dashboard_root_path, alert: "You are not authorized to perform this action"
    end
  end

  private

  def authorize_user!
    authorize(@record, policy_class:)
  end

  def authorize_carrier!
    return if current_carrier == current_user.carrier

    sign_out(current_user)
    redirect_to(new_user_session_url(host: current_carrier.subdomain_host))
  end

  def select_account_membership!
    return if current_user.carrier_user?
    return if current_user.current_account_membership.present?

    if current_user.account_memberships.blank?
      sign_out(current_user)
      redirect_to(new_user_session_path, alert: "You are not a member of any accounts")
    else
      current_user.update!(current_account_membership: current_user.account_memberships.first!)
    end
  end

  def policy_class
    "#{controller_name.classify}Policy".constantize
  end

  def current_account_membership
    current_user.current_account_membership
  end

  def current_account
    current_account_membership.account
  end

  def parent_scope
    current_user.carrier_user? ? current_carrier : current_account
  end
end
