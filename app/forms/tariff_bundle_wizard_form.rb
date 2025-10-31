class TariffBundleWizardForm < ApplicationForm
  attribute :object, default: -> { TariffBundle.new }
  attribute :carrier
  attribute :name
  attribute :description
  attribute :tariffs, FormCollectionType.new(form: TariffBundleWizardLineItemForm), default: []

  validates :name, presence: true

  validate :validate_name
  validate :validate_tariffs

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffBundle")
  end

  def initialize(**)
    super(**)
    self.object.carrier = carrier
    self.tariffs = build_tariffs if tariffs.blank?
  end

  def tariffs=(value)
    super
    tariffs.each { _1.tariff_bundle = object }
  end

  def save
    return false if invalid?

    ApplicationRecord.transaction do
      object.attributes = {
        name:,
        description: name.presence
      }

      object.save!
      tariffs.all? { _1.save }
    end
  end

  private

  def build_tariffs
    defaults = TariffSchedule.category.values.map do |category|
      TariffBundleWizardLineItemForm.new(category:, enabled: true, tariff_bundle: object)
    end
    FormCollection.new(defaults, form: TariffBundleWizardLineItemForm)
  end

  def validate_name
    return unless carrier.tariff_bundles.exists?(name:)

    errors.add(:name, :taken)
  end

  def validate_tariffs
    tariffs.each(&:valid?)
    return if tariffs.any?(&:enabled) && tariffs.all? { _1.errors.empty? }

    errors.add(:tariffs, :invalid)

    tariffs.first.errors.add(:rate, :blank) if tariffs.none?(&:enabled)
  end
end
