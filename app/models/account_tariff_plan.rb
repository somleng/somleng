class AccountTariffPlan < ApplicationRecord
  extend Enumerize

  belongs_to :account
  belongs_to :tariff_plan

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue
end
