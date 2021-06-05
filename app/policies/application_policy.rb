class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record = nil)
    @user = user
    @record = record
  end

  def index?
    user.current_organization.present?
  end

  def show?
    index?
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    manage?
  end

  def create?
    manage?
  end

  def update?
    manage?
  end

  def manage?
    false
  end

  private

  def carrier_admin?
    user.current_organization.carrier? && (user.owner? || user.admin?)
  end

  def carrier_owner?
    user.current_organization.carrier? && user.owner?
  end

  def account_owner?
    user.current_organization.account? && user.current_account_membership.owner?
  end
end
