class PhoneNumberPlan < ApplicationRecord
  extend Enumerize

  attribute :number, PhoneNumberType.new

  belongs_to :carrier
  belongs_to :account
  belongs_to :phone_number, optional: true

  enumerize :status, in: [ :active, :canceled ], default: :active, scope: :shallow
  monetize :price_cents, with_model_currency: :currency

  before_validation :set_defaults, on: :create

  validates :currency, comparison: { equal_to: ->(this) { this.account.billing_currency } }

  private

  def set_defaults
    return if phone_number.blank?

    self.number = phone_number.number
    self.account = phone_number.account
    self.carrier =  phone_number.carrier
    self.price = phone_number.price
  end
end
