class TariffPackageForm < ApplicationForm
  attribute :carrier
  attribute :category
  attribute :object, default: -> { TariffPackage.new }
  attribute :name
  attribute :description
  attribute :tiers

  attribute :tiers,
            FormCollectionType.new(form: TariffPlanTierForm),
            default: []

  enumerize :category, in: TariffPackage.category.values

  validates :name, :category, presence: true

  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffPackage")
  end

  def self.initialize_with(tariff_package)
    new(
      object: tariff_package,
      carrier: tariff_package.carrier,
      name: tariff_package.name,
      description: tariff_package.description,
      category: tariff_package.category
    )
  end

  def initialize(**)
    super(**)
    object.carrier = carrier
    self.tiers = build_tiers if tiers.blank?
  end

  def tiers=(value)
    super(value)
    tiers.each { _1.attributes = { tariff_package: object } }
  end


  def save
    return false if invalid?

    object.attributes = {
      carrier:,
      category:,
      name:,
      description: description.presence
    }

    object.save!

    tiers.all?(&:save)
  end

  def retained_tiers
    tiers.select(&:retain?)
  end

  private

  def build_tiers
    FormCollection.new([ TariffPlanTierForm.new ], form: TariffPlanTierForm)
  end
end
