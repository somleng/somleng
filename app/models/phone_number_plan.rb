class PhoneNumberPlan < ApplicationRecord
  extend Enumerize

  attribute :number, PhoneNumberType.new

  belongs_to :carrier
  belongs_to :account
  belongs_to :phone_number, optional: true
  belongs_to :canceled_by, class_name: "User", optional: true
  has_one :incoming_phone_number

  enumerize :status, in: [ :active, :canceled ], default: :active, scope: :shallow, predicates: true
  monetize :amount_cents, with_model_currency: :currency, numericality: {
    greater_than_or_equal_to: 0
  }
  before_validation :set_defaults, on: :create

  validates :incoming_phone_number, presence: true
  validates :currency, comparison: { equal_to: ->(this) { this.account.billing_currency } }

  def cancel!(**options)
    update!(status: :canceled, canceled_at: Time.current, **options)
  end

  private

  def set_defaults
    return if phone_number.blank?

    self.incoming_phone_number || build_incoming_phone_number
    self.number ||= phone_number.number
    self.carrier ||= phone_number.carrier
    self.currency ||= phone_number.currency
    self.amount ||= phone_number.price
  end
end
