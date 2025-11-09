class TariffPackageForm < ApplicationForm
  attribute :carrier
  attribute :category
  attribute :object, default: -> { TariffPackage.new }
  attribute :name
  attribute :description

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

  def save
    return false if invalid?

    object.attributes = {
      carrier:,
      category:,
      name:,
      description: description.presence
    }

    object.save!

    true
  end
end
