class TariffBundleForm < ApplicationForm
  extend Enumerize

  attribute :carrier
  attribute :object, default: -> { TariffBundle.new }
  attribute :name
  attribute :description

  validates :name, presence: true

  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffBundle")
  end

  def self.initialize_with(tariff_bundle)
    new(
      object: tariff_bundle,
      carrier: tariff_bundle.carrier,
      name: tariff_bundle.name,
      description: tariff_bundle.description
    )
  end

  def save
    return false if invalid?

    object.attributes = {
      carrier:,
      name:,
      description: description.presence
    }

    object.save!

    true
  end
end
