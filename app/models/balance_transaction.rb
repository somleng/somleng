class BalanceTransaction < ApplicationRecord
  extend Enumerize
  self.inheritance_column = :_type_disabled

  belongs_to :account
  belongs_to :carrier
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :message, optional: true
  belongs_to :phone_call, optional: true

  enumerize :type, in: [ :topup, :adjustment, :charge ], predicates: true, scope: :shallow
  enumerize :charge_category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue

  def credit?
    return true if topup?
    return amount.positive? if adjustment?

    raise "Invalid balance transaction type: #{type}"
  end

  def amount
    InfinitePrecisionMoney.new(amount_cents, currency)
  end
end
