class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record = nil)
    @user = user
    @record = record
  end

  def index?
    read?
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

  def read?
    user.current_organization.present?
  end

  private

  def carrier_admin?
    managing_carrier? && (user.owner? || user.admin?)
  end

  def carrier_owner?
    managing_carrier? && user.owner?
  end

  def account_owner?
    managing_account? && user.current_account_membership.owner?
  end

  def account_admin?
    managing_account? && (user.current_account_membership.owner? || user.current_account_membership.admin?)
  end

  def managing_account?
    user.current_organization.account?
  end

  def managing_carrier?
    user.current_organization.carrier?
  end
end
