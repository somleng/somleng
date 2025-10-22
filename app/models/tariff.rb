class Tariff < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  has_one :call_tariff, dependent: :destroy, autosave: true, inverse_of: :tariff
  has_one :message_tariff, dependent: :destroy, autosave: true, inverse_of: :tariff

  attribute :currency, CurrencyType.new

  enumerize :category, in: [ :message, :call ], predicates: true

  def rate
    if message?
      message_tariff.rate
    elsif call?
      call_tariff.per_minute_rate
    end
  end
end
