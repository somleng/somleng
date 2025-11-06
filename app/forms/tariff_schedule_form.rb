class TariffScheduleForm < ApplicationForm
  attribute :carrier
  attribute :category
  attribute :object, default: -> { TariffSchedule.new }
  attribute :name
  attribute :description

  attribute :destination_tariffs,
            FormCollectionType.new(form: DestinationTariffForm),
            default: []

  enumerize :category, in: TariffSchedule.category.values

  validates :name, :category, presence: true
  validate :validate_destination_tariffs
  validate :validate_name

  delegate :persisted?, :new_record?, :id, to: :object
  delegate :billing_currency, to: :carrier

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffSchedule")
  end

  def self.initialize_with(tariff_schedule)
    new(
      object: tariff_schedule,
      carrier: tariff_schedule.carrier,
      name: tariff_schedule.name,
      description: tariff_schedule.description,
      category: tariff_schedule.category,
      destination_tariffs: tariff_schedule.destination_tariffs
    )
  end

  def initialize(**)
    super(**)
    object.carrier = carrier
    self.destination_tariffs = build_destination_tariffs if destination_tariffs.blank?
  end

  def destination_tariffs=(value)
    super(value)
    destination_tariffs.each { _1.attributes = { tariff_schedule: object, parent_form: self } }
  end

  def save
    return false if invalid?

    ApplicationRecord.transaction do
      object.attributes = {
        carrier:,
        category:,
        name:,
        description: description.presence
      }

      object.save!

      destination_tariffs.all?(&:save)
    end
  end

  def retained_destination_tariffs
    destination_tariffs.select(&:retain?)
  end

  private

  def build_destination_tariffs
    FormCollection.new([ DestinationTariffForm.new ], form: DestinationTariffForm)
  end

  def validate_destination_tariffs
    retained_destination_tariffs.each(&:valid?)

    destination_group_ids = retained_destination_tariffs.select { _1.destination_group_id.present? }.group_by(&:destination_group_id)

    destination_group_ids.each_value do |forms|
      next if forms.size <= 1

      forms.drop(1).each do |duplicate|
        duplicate.errors.add(:destination_group_id, :taken)
      end
    end

    return if retained_destination_tariffs.all? { _1.errors.empty? }

    errors.add(:destination_tariffs, :invalid)
  end

  def validate_name
    return unless carrier.tariff_schedules.where.not(id: object.id).exists?(name:, category:)

    errors.add(:name, :taken)
  end
end
