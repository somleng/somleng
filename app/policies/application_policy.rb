class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record = nil)
    @user = user
    @record = record
  end

  def index?
    true
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
    user.admin?
  end
end
