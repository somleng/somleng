class TariffPackageTariffForm < ApplicationForm
  attribute :parent_form
  attribute :package
  attribute :rate, :decimal
  attribute :enabled, :boolean
  attribute :category

  delegate :carrier, :name, to: :parent_form
  delegate :billing_currency, to: :carrier

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue

  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0, allow_blank: true }, if: ->(form) { form.enabled }
  validate  :validate_name

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffPackagePlan")
  end

  def save
    return false if invalid?
    return true unless enabled?

    ApplicationRecord.transaction do
      CreateTariffPackagePlanWithDefaults.call(
        package:,
        category:,
        rate: InfinitePrecisionMoney.from_amount(rate, billing_currency)
      )
    end
  end

  def rate_unit
    TariffDecorator.new(Tariff.new(currency: billing_currency, category: category.tariff_category)).rate_unit(with_currency: true)
  end

  def hint
    "Enter the rate for #{category.humanize.downcase} in #{billing_currency.name}."
  end

  def enabled?
    !!enabled
  end

  private

  def validate_name
    return if !carrier.tariff_plans.exists?(name:, category:) && !carrier.tariff_schedules.exists?(name:, category:)

    errors.add(:rate, :taken)
  end
end
