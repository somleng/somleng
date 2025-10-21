class TariffScheduleForm < ApplicationForm
  extend Enumerize

  attribute :carrier
  attribute :category
  attribute :object, default: -> { TariffSchedule.new }
  attribute :name
  attribute :description

  enumerize :category, in: TariffSchedule.category.values

  validates :name, :category, presence: true

  delegate :persisted?, :new_record?, :id, to: :object


  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffSchedule")
  end

  def self.initialize_with(tariff_schedule)
    new(
      object: tariff_schedule,
      carrier: tariff_schedule.carrier,
      name: tariff_schedule.name,
      description: tariff_schedule.description,
      category: tariff_schedule.category
    )
  end

  def save
    return false if invalid?

    object.attributes = {
      carrier:,
      category:,
      name:,
      description: description.presence
    }

    object.save!

    true
  end
end
