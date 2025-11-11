class TariffPackageLineItem < ApplicationRecord
  extend Enumerize

  belongs_to :tariff_package
  belongs_to :tariff_plan

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue
end
