module UserAuthorization
  extend ActiveSupport::Concern
  include Pundit

  included do
    helper_method :current_carrier
    helper_method :current_organization
    helper_method :current_account
    helper_method :current_account_membership

    before_action :authorize_user!
    after_action :verify_authorized
    rescue_from Pundit::NotAuthorizedError do
      redirect_to dashboard_root_path, alert: "You are not authorized to perform this action"
    end
  end

  private

  def authorize_user!
    authorize(@record, policy_class: policy_class)
  end

  def policy_class
    "#{controller_name.classify}Policy".constantize
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

    def account?
      false
    end

    def name
      "Select Account"
    end

    def present?
      false
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
