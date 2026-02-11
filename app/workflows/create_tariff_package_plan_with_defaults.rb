class CreateTariffPackagePlanWithDefaults < ApplicationWorkflow
  attr_reader :package, :category, :rate

  delegate :carrier, :name, to: :package, private: true

  def initialize(package:, category:, rate:)
    super()
    @package = package
    @category = category
    @rate = rate
  end

  def call
    plan = create_plan
    add_plan_to_package(plan:)
    schedule = create_schedule
    add_schedule_to_plan(plan:, schedule:)
    tariff = create_tariff
    add_tariff_to_schedule(tariff:, schedule:)
  end

  private

  def create_plan
    carrier.tariff_plans.create!(name:, category:)
  end

  def add_plan_to_package(plan:)
    package.package_plans.create!(package:, plan:, category:)
  end

  def create_schedule
    carrier.tariff_schedules.create!(name:, category:)
  end

  def add_schedule_to_plan(schedule:, plan:)
    plan.tiers.create!(plan:, schedule:)
  end

  def create_tariff
    carrier.tariffs.create!(
      rate_cents: rate.cents,
      currency: carrier.billing_currency,
      category: category.tariff_category
    )
  end

  def add_tariff_to_schedule(tariff:, schedule:)
    schedule.destination_tariffs.create!(destination_group:, tariff:)
  end

  def destination_group
    @destination_group ||= carrier.destination_groups.find_or_create_by!(catch_all: true)
  end
end
