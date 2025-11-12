class TariffPlanSubscription < ApplicationRecord
  extend Enumerize

  belongs_to :account
  belongs_to :plan, class_name: "TariffPlan"

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue
end
