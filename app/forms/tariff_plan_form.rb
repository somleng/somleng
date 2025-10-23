class TariffPlanForm < ApplicationForm
  attribute :carrier
  attribute :object, default: -> { TariffPlan.new }
  attribute :tariff_package_id
  attribute :tariff_schedule_id

  validates :tariff_schedule_id, presence: true
  validate :validate_tariff_schedule_uniqueness

  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffPlan")
  end

  def save
    return false if invalid?

    object.attributes = {
      tariff_package:,
      tariff_schedule: tariff_schedules.find(tariff_schedule_id)
    }

    object.save!

    true
  end

  def tariff_package
    @tariff_package ||= carrier.tariff_packages.find(tariff_package_id)
  end

  def tariff_packages_options_for_select
    options_for_select([ tariff_package ]) { |item| [ item.name, item.id ] }
  end

  def tariff_schedules_options_for_select
    options_for_select(tariff_schedules) { |item| [ item.name, item.id ] }
  end

  private

  def tariff_schedules
    @tariff_schedules ||= carrier.tariff_schedules.where(category: tariff_package.category)
  end

  def options_for_select(collection)
    collection.map do |item|
      decorated_item = item.decorated
      yield(decorated_item)
    end
  end

  def validate_tariff_schedule_uniqueness
    return unless carrier.tariff_plans.exists?(
      tariff_package_id: tariff_package_id,
      tariff_schedule_id: tariff_schedule_id
    )

    errors.add(:tariff_schedule_id, :taken)
  end
end
