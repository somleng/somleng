class BalanceTransactionPolicy < ApplicationPolicy
  def read?
    true
  end

  def manage?
    carrier_admin?
  end
end
