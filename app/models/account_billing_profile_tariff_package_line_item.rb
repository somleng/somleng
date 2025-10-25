class AccountBillingProfileTariffPackageLineItem < ApplicationRecord
  extend Enumerize

  belongs_to :account_billing_profile
  belongs_to :tariff_package

  enumerize :category, in: TariffSchedule.category.values
end
