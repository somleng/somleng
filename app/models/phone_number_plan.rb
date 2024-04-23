class PhoneNumberPlan < ApplicationRecord
  extend Enumerize

  attribute :number, PhoneNumberType.new

  belongs_to :carrier
  belongs_to :account
  belongs_to :phone_number, optional: true

  enumerize :status, in: [ :active, :canceled ], default: :active, scope: :shallow, predicates: true
  monetize :amount_cents, with_model_currency: :currency, numericality: {
    greater_than_or_equal_to: 0
  }
  before_validation :set_defaults, on: :create

  validates :currency, comparison: { equal_to: ->(this) { this.account.billing_currency } }

  def cancel!
    update!(status: :canceled, canceled_at: Time.current)
  end

  private

  def set_defaults
    return if phone_number.blank?

    self.number = phone_number.number
    self.carrier =  phone_number.carrier
    self.amount = phone_number.price
  end
end
