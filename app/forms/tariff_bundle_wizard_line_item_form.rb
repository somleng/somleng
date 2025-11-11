class TariffBundleWizardLineItemForm < ApplicationForm
  attribute :tariff_bundle
  attribute :rate, :decimal
  attribute :enabled, :boolean
  attribute :category
  attribute :object, default: -> { TariffBundleLineItem.new }

  delegate :carrier, :name, to: :tariff_bundle
  delegate :billing_currency, to: :carrier

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue

  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0, allow_blank: true }, if: ->(form) { form.enabled }

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffBundleLineItem")
  end

  def save
    return false if invalid?
    return true unless enabled

    create_tariff_bundle_line_item
  end

  def rate_unit
    result = billing_currency.symbol
    result += " / min" if category.type.calls?
    result
  end

  def hint
    "Enter the rate for #{category.humanize.downcase} in #{billing_currency.name}."
  end

  private

  def create_tariff_bundle_line_item
    ApplicationRecord.transaction do
      tariff_plan = carrier.tariff_plans.find_or_create_by!(name:, category:)
      object.category = category
      object.tariff_bundle = tariff_bundle
      object.tariff_plan = tariff_plan
      object.save!
      tariff_schedule = carrier.tariff_schedules.find_or_create_by!(name:, category:)
      tariff_plan.tariff_plans.find_or_create_by!(tariff_schedule:)
      destination_group = carrier.destination_groups.find_or_create_by!(catch_all: true)
      destination_tariff = tariff_schedule.destination_tariffs.find_or_initialize_by(destination_group:)

      return if destination_tariff.persisted?

      tariff = carrier.tariffs.create!(name:, category: category.tariff_category, currency: billing_currency)
      rate_cents = InfinitePrecisionMoney.from_amount(rate, tariff.currency).cents
      if category.tariff_category.call?
        tariff.create_call_tariff!(per_minute_rate_cents: rate_cents)
      elsif category.tariff_category.message?
        tariff.create_message_tariff!(rate_cents:)
      end

      destination_tariff.tariff = tariff
      destination_tariff.save!
    end
  end
end
