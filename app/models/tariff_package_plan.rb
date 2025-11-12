class TariffPackagePlan < ApplicationRecord
  extend Enumerize

  belongs_to :package, class_name: "TariffPackage"
  belongs_to :plan, class_name: "TariffPlan"

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue
end
