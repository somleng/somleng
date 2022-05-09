module UserAuthorization
  extend ActiveSupport::Concern
  include Pundit::Authorization

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
    authorize(@record, policy_class:)
  end

  def policy_class
    "#{controller_name.classify}Policy".constantize
  end

  def current_organization
    @current_organization ||= begin
      if current_user.carrier_role.present?
        Organization.new(current_carrier)
      else
        current_account = current_account_membership&.account
        current_account.present? ? Organization.new(current_account) : BlankOrganization.new
      end
    end
  end

  def current_account
    @current_account ||= current_account_membership.account
  end

  def current_carrier
    current_user.carrier
  end

  def authorized_carrier
    current_carrier
  end

  def current_account_membership
    @current_account_membership ||= begin
      session[:current_account_membership] ||= current_user.current_account_membership_id
      account_membership = current_user.account_memberships.find_by(id: session[:current_account_membership])
      account_membership.present? ? account_membership : BlankAccountMembership.new
    end
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

  class BlankOrganization
    def carrier?
      false
    end

    def account?
      false
    end

    def present?
      false
    end

    def carrier; end
  end

  class BlankAccountMembership
    def owner?
      false
    end

    def account; end

    def user; end
  end
end
