class TariffPackageWizardForm < ApplicationForm
  attribute :object, default: -> { TariffPackage.new }
  attribute :carrier
  attribute :name
  attribute :description
  attribute :tariffs, FormCollectionType.new(form: TariffPackageWizardLineItemForm), default: []

  validates :name, presence: true

  validate :validate_name
  validate :validate_tariffs

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffPackage")
  end

  def initialize(**)
    super(**)
    self.object.carrier = carrier
    self.tariffs = build_tariffs if tariffs.blank?
  end

  def tariffs=(value)
    super
    tariffs.each { _1.tariff_package = object }
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
      TariffPackageWizardLineItemForm.new(category:, enabled: false, tariff_package: object)
    end
    FormCollection.new(defaults, form: TariffPackageWizardLineItemForm)
  end

  def validate_name
    return unless carrier.tariff_packages.exists?(name:)

    errors.add(:name, :taken)
  end

  def validate_tariffs
    tariffs.each(&:valid?)
    return if tariffs.any?(&:enabled) && tariffs.all? { _1.errors.empty? }

    errors.add(:tariffs, :invalid)

    tariffs.first.errors.add(:rate, :blank) if tariffs.none?(&:enabled)
  end
end
