class AccountBillingProfile < ApplicationRecord
  belongs_to :account
  belongs_to :tariff_bundle, optional: true
end
