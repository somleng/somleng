class TariffBundleLineItem < ApplicationRecord
  extend Enumerize

  belongs_to :tariff_bundle
  belongs_to :tariff_package

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue
end
