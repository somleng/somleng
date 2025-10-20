class CallTariff < ApplicationRecord
  belongs_to :tariff

  def per_minute_rate
    InfinitePrecisionMoney.new(per_minute_rate_cents, tariff.currency)
  end

  def connection_fee
    InfinitePrecisionMoney.new(connection_fee_cents, tariff.currency)
  end
end
