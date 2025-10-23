class AccountBillingProfileTariffBundleLineItem < ApplicationRecord
  extend Enumerize

  belongs_to :account_billing_profile
  belongs_to :tariff_bundle_line_item

  enumerize :category, in: TariffSchedule.category.values
end
