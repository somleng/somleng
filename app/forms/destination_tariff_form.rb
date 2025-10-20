class DestinationTariffForm < ApplicationForm
  attribute :carrier
  attribute :object, default: -> { DestinationTariff.new }
  attribute :tariff_schedule_id
  attribute :tariff_id
  attribute :destination_group_id

  validates :tariff_schedule_id, :tariff_id, :destination_group_id, presence: true

  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "DestinationTariff")
  end

  def save
    return false if invalid?

    object.attributes = {
      tariff_schedule: tariff_schedules.find(tariff_schedule_id),
      tariff: tariffs.find(tariff_id),
      destination_group: destination_groups.find(destination_group_id)
    }

    object.save!

    true
  end

  def tariff_schedules_options_for_select
    options_for_select(tariff_schedules) { |item| [ item.name, item.id ] }
  end

  def tariff_options_for_select
    options_for_select(tariffs) { |item| [ item.display_name, item.id ] }
  end

  def destination_group_options_for_select
    options_for_select(destination_groups) { |item| [ item.name, item.id ] }
  end

  private

  def tariff_schedules
    @tariff_schedules ||= carrier.tariff_schedules
  end

  def tariffs
    @tariffs ||= carrier.tariffs
  end

  def destination_groups
    @destination_groups ||= carrier.destination_groups
  end

  def options_for_select(collection)
    collection.map do |item|
      decorated_item = item.decorated
      yield(decorated_item)
    end
  end
end
