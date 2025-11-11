class TariffPlanTierForm < ApplicationForm
  attribute :object, default: -> { TariffPlanTier.new }
  attribute :id
  attribute :_destroy, :boolean, default: false
  attribute :tariff_package
  attribute :tariff_schedule_id
  attribute :weight, :decimal, default: -> { TariffPlanTier::DEFAULT_WEIGHT }

  validates :tariff_schedule_id, presence: true
  validates :weight, presence: true, numericality: { greater_than: 0, less_than: 10 ** 6 }

  delegate :carrier, :category, to: :tariff_package
  delegate :persisted?, :new_record?, to: :object

  before_validation :set_object

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffPlan")
  end

  def self.initialize_with(object)
    new(
      object:,
      id: object.id,
      tariff_package: object.package,
      tariff_schedule_id: object.tariff_schedule_id,
      weight: object.weight
    )
  end

  def save
    return false if invalid?
    return object.destroy! unless retain?

    object.attributes = {
      package: tariff_package,
      weight:,
      schedule: carrier.tariff_schedules.where(category:).find(tariff_schedule_id)
    }

    object.save!

    true
  end

  def tariff_schedules_by_category
    carrier.tariff_schedules.group_by(&:category).transform_values do |schedules|
      DecoratedCollection.new(schedules).map { [ _1.name, _1.id ] }
    end
  end

  def tariff_schedules_options_for_select
    DecoratedCollection.new(carrier.tariff_schedules.where(id: tariff_schedule_id)).map { [ _1.name, _1.id ] }
  end

  def retain?
    !_destroy
  end

  private

  def set_object
    return if id.blank?
    return if tariff_package.blank?

    self.object = tariff_package.tiers.find(id)
    self.tariff_schedule_id = object.tariff_schedule_id
  end
end
