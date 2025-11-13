class Tariff < ApplicationRecord
  extend Enumerize

  belongs_to :carrier

  attribute :currency, CurrencyType.new

  enumerize :category, in: [ :message, :call ], predicates: true

  def rate
    InfinitePrecisionMoney.new(rate_cents, currency)
  end
end
