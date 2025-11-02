class DestinationTariffForm < ApplicationForm
  attribute :object, default: -> { DestinationTariff.new }
  attribute :tariff_schedule
  attribute :destination_group_id
  attribute :rate
  attribute :_destroy

  validate :validate_destination_group_uniqueness

  delegate :carrier, :category, to: :tariff_schedule
  delegate :billing_currency, to: :carrier
  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "DestinationTariff")
  end

  def save
    return false if invalid?

    object.attributes = {
      tariff_schedule:,
      tariff: tariffs.find(tariff_id),
      destination_group: destination_groups.find(destination_group_id)
    }

    object.save!

    true
  end

  def destination_groups_options_for_select
    DecoratedCollection.new(destination_groups).map { [ _1.name, _1.id ] }
  end

  def rate_unit
    result = billing_currency.symbol
    return result if category.blank?

    result += " / min" if category.type.calls?
    result
  end

  def hint
    "Enter the rate in #{billing_currency.name}."
  end

  private

  def destination_groups
    @destination_groups ||= carrier.destination_groups
  end

  def validate_destination_group_uniqueness
    return unless carrier.destination_tariffs.exists?(
      tariff_schedule_id: tariff_schedule_id,
      destination_group_id: destination_group_id,
    )

    errors.add(:destination_group_id, :taken)
  end
end
