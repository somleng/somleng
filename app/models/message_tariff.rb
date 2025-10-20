class MessageTariff < ApplicationRecord
  belongs_to :tariff

  def rate
    InfinitePrecisionMoney.new(rate_cents, tariff.currency)
  end
end
