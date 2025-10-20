class TariffForm < ApplicationForm
  extend Enumerize

  attribute :carrier
  attribute :object, default: -> { Tariff.new }
  attribute :name
  attribute :description
  attribute :category
  attribute :currency, CurrencyType.new
  attribute :message_rate, :decimal, default: 0
  attribute :call_per_minute_rate, :decimal, default: 0
  attribute :call_connection_fee, :decimal, default: 0

  validates :name, :category, presence: true
  validates :message_rate, presence: true, if: :message?, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
  validates :call_per_minute_rate, presence: true, if: :call?, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
  validates :call_connection_fee, numericality: { greater_than_or_equal_to: 0, allow_blank: true }

  enumerize :category, in: Tariff.category.values, predicates: true

  delegate :persisted?, :new_record?, :id, to: :object

  def initialize(**)
    super(**)
    self.currency ||= carrier.billing_currency
    self.category = object.category if persisted?
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Tariff")
  end

  def self.initialize_with(tariff)
    new(
      object: tariff,
      carrier: tariff.carrier,
      name: tariff.name,
      description: tariff.description,
      category: tariff.category,
      message_rate: tariff.message_tariff&.rate,
      call_per_minute_rate: tariff.call_tariff&.per_minute_rate,
      call_connection_fee: tariff.call_tariff&.connection_fee
    )
  end

  def save
    return false if invalid?

    object.attributes = {
      carrier:,
      name:,
      description: description.presence,
      category:,
      currency:
    }

    if message?
      message_tariff ||= object.build_message_tariff
      message_tariff.attributes = {
        rate_cents: rate_to_cents(message_rate)
      }
    elsif call?
      call_tariff ||= object.build_call_tariff
      call_tariff.attributes = {
        per_minute_rate_cents: rate_to_cents(call_per_minute_rate),
        connection_fee_cents: rate_to_cents(call_connection_fee)
      }
    end

    object.save!

    true
  end

  private

  def rate_to_cents(rate)
    InfinitePrecisionMoney.from_amount(rate.presence.to_d, currency).cents
  end
end
