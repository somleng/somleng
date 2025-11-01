class TariffPlanForm < ApplicationForm
  attribute :carrier
  attribute :object, default: -> { TariffPlan.new }
  attribute :tariff_package_id
  attribute :tariff_schedule_id
  attribute :weight, :decimal, default: -> { TariffPlan::DEFAULT_WEIGHT }

  validates :tariff_schedule_id, presence: true
  validates :weight, presence: true, numericality: { greater_than: 0, less_than: 10 ** 6 }

  validate :validate_tariff_schedule_uniqueness

  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffPlan")
  end

  def self.initialize_with(object)
    new(
      object:,
      carrier: object.tariff_package.carrier,
      tariff_package_id: object.tariff_package_id,
      tariff_schedule_id: object.tariff_schedule_id,
      weight: object.weight
    )
  end

  def save
    return false if invalid?

    object.attributes = {
      tariff_package:,
      weight:,
      tariff_schedule: tariff_schedules.find(tariff_schedule_id)
    }

    object.save!

    true
  end

  def tariff_package
    @tariff_package ||= carrier.tariff_packages.find(tariff_package_id)
  end

  def tariff_packages_options_for_select
    DecoratedCollection.new([ tariff_package ]).map { [ _1.name, _1.id ] }
  end

  def tariff_schedules_options_for_select
    DecoratedCollection.new(tariff_schedules).map { [ _1.name, _1.id ] }
  end

  private

  def tariff_schedules
    @tariff_schedules ||= carrier.tariff_schedules.where(category: tariff_package.category)
  end

  def validate_tariff_schedule_uniqueness
    return if persisted?
    return unless carrier.tariff_plans.exists?(
      tariff_package_id: tariff_package_id,
      tariff_schedule_id: tariff_schedule_id
    )

    errors.add(:tariff_schedule_id, :taken)
  end
end
