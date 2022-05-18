module UserAuthorization
  extend ActiveSupport::Concern
  include Pundit::Authorization
  include Devise::Controllers::SignInOut

  included do
    helper_method :current_carrier
    helper_method :current_organization
    helper_method :current_account
    helper_method :current_account_membership

    before_action :select_account_membership!
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

  def select_account_membership!
    return if current_user.carrier_role.present?
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

  def current_organization
    @current_organization ||= if current_user.carrier_role.present?
                                Organization.new(current_carrier)
                              else
                                Organization.new(current_account)
                              end
  end

  def current_account_membership
    current_user.current_account_membership
  end

  def current_account
    current_account_membership.account
  end

  def current_carrier
    current_user.carrier
  end

  def authorized_carrier
    current_carrier
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

    def carrier
      account? ? __getobj__.carrier : __getobj__
    end
  end
end
