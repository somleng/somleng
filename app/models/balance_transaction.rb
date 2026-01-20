class BalanceTransaction < ApplicationRecord
  extend Enumerize
  self.inheritance_column = :_type_disabled

  belongs_to :account
  belongs_to :carrier
  belongs_to :created_by, class_name: "User", optional: true

  enumerize :type, in: [ :topup, :adjustment, :charge ], predicates: true, scope: :shallow

  monetize :amount_cents, with_model_currency: :currency

  def credit?
    return true if topup?
    return amount.positive? if adjustment?

    raise "Invalid balance transaction type: #{type}"
  end
end
