class DestinationTariffForm < ApplicationForm
  attribute :id
  attribute :object, default: -> { DestinationTariff.new }
  attribute :schedule
  attribute :destination_group_id
  attribute :rate
  attribute :currency
  attribute :_destroy, :boolean, default: false

  validates :destination_group_id, presence: true
  validates :rate,
    presence: true,
    numericality: { greater_than_or_equal_to: 0, less_than: 10**10 }

  delegate :carrier, :category, to: :schedule
  delegate :persisted?, :new_record?, to: :object

  before_validation :set_object

  def self.model_name
    ActiveModel::Name.new(self, nil, "DestinationTariff")
  end

  def self.initialize_with(object)
    new(
      object:,
      id: object.id,
      schedule: object.schedule,
      destination_group_id: object.destination_group_id,
      rate: object.tariff.rate,
      currency: object.tariff.currency
    )
  end

  def save
    return false if invalid?
    return object.destroy! unless retain?

    object.attributes = {
      schedule:,
      destination_group: destination_groups.find(destination_group_id)
    }

    tariff = object.tariff ||= object.build_tariff
    tariff.attributes = {
      carrier:,
      currency:,
      category: category.tariff_category,
      rate_cents: rate_to_cents(rate)
    }

    object.save!

    true
  end

  def retain?
    !_destroy
  end

  def destination_groups_options_for_select
    DecoratedCollection.new(destination_groups).map { [ _1.name, _1.id ] }
  end

  def rate_unit
    result = currency.symbol
    return result if category.blank?

    format_rate_unit(category)
  end

  def hint
    "Enter the rate in #{currency.name}."
  end

  def rate_unit_by_category
    TariffSchedule.category.values.each_with_object({}) do |category, result|
      result[category] = format_rate_unit(category)
    end
  end

  def currency
    super || carrier.billing_currency
  end

  private

  def format_rate_unit(category)
    [ currency.symbol, category.rate_unit ].join(" ")
  end

  def destination_groups
    @destination_groups ||= carrier.destination_groups
  end

  def rate_to_cents(rate)
    InfinitePrecisionMoney.from_amount(rate.presence.to_d, currency).cents
  end

  def set_object
    return if id.blank?
    return if schedule.blank?

    self.object = schedule.destination_tariffs.find(id)
  end
end
