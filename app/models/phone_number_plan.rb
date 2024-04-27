class PhoneNumberPlan < ApplicationRecord
  extend Enumerize

  attribute :number, PhoneNumberType.new

  belongs_to :carrier
  belongs_to :account
  belongs_to :phone_number, optional: true
  has_one :incoming_phone_number

  enumerize :status, in: [ :active, :canceled ], default: :active, scope: :shallow, predicates: true
  monetize :amount_cents, with_model_currency: :currency, numericality: {
    greater_than_or_equal_to: 0
  }

  validates :incoming_phone_number, presence: true

  def cancel!
    update!(status: :canceled, canceled_at: Time.current)
  end
end
