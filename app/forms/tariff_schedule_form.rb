class TariffScheduleForm < ApplicationForm
  attribute :carrier
  attribute :object, default: -> { TariffSchedule.new }
  attribute :name
  attribute :description

  validates :name, presence: true

  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffSchedule")
  end

  def self.initialize_with(tariff_schedule)
    new(
      object: tariff_schedule,
      carrier: tariff_schedule.carrier,
      name: tariff_schedule.name,
      description: tariff_schedule.description
    )
  end

  def save
    return false if invalid?

    object.attributes = {
      carrier:,
      name:,
      description: description.presence
    }

    object.save!

    true
  end
end
