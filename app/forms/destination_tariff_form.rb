class DestinationTariffForm < ApplicationForm
  attribute :carrier
  attribute :object, default: -> { DestinationTariff.new }
  attribute :tariff_schedule_id
  attribute :tariff_id
  attribute :destination_group_id

  validates :tariff_schedule_id, :tariff_id, :destination_group_id, presence: true
  validate :validate_destination_group_uniqueness

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

  def tariff_schedule
    @tariff_schedule ||= carrier.tariff_schedules.find(tariff_schedule_id)
  end

  def tariff_schedules_options_for_select
    DecoratedCollection.new([ tariff_schedule ]).map { [ _1.name, _1.id ] }
  end

  def tariff_options_for_select
    DecoratedCollection.new([ tariffs ]).map { [ _1.name, _1.id ] }
  end

  def destination_group_options_for_select
    DecoratedCollection.new(destination_groups).map { [ _1.name, _1.id ] }
  end

  private

  def tariffs
    @tariffs ||= carrier.tariffs.where(category: tariff_schedule.category.tariff_category)
  end

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
