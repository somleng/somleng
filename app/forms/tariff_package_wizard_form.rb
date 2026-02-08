class TariffPackageWizardForm < ApplicationForm
  attribute :object, default: -> { TariffPackage.new }
  attribute :carrier
  attribute :name
  attribute :description
  attribute :tariffs, FormCollectionType.new(form: TariffPackageTariffForm), default: []

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
    tariffs.each { _1.attributes = { package: object, parent_form: self } }
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
      TariffPackageTariffForm.new(category:, enabled: false, package: object)
    end
    FormCollection.new(defaults, form: TariffPackageTariffForm)
  end

  def validate_name
    return unless carrier.tariff_packages.exists?(name:)

    errors.add(:name, :taken)
  end

  def validate_tariffs
    if enabled_tariffs.blank?
      tariffs.first.errors.add(:rate, :blank)
      return errors.add(:tariffs, :invalid)
    end

    enabled_tariffs.each(&:valid?)
    errors.add(:tariffs, :invalid) if enabled_tariffs.any? { _1.errors.present? }
  end

  def enabled_tariffs
    tariffs.select(&:enabled?)
  end
end
