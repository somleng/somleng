class PhoneNumberPlan < ApplicationRecord
  belongs_to :carrier
  belongs_to :account
  belongs_to :phone_number, optional: true

  monetize :price_cents, with_model_currency: :currency

  def canceled?
    canceled_at.present?
  end

  def active?
    started_at.present? && !canceled?
  end
end
