class AccountTariffPackage < ApplicationRecord
  extend Enumerize

  belongs_to :account
  belongs_to :tariff_package

  enumerize :category, in: TariffSchedule.category.values
end
