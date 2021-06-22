class CarrierSettingsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :name
  attribute :country
  attribute :logo

  delegate :persisted?, :id, to: :carrier

  validates :name, presence: true
  validates :country, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }

  def self.model_name
    ActiveModel::Name.new(self, nil, "CarrierSettings")
  end

  def self.initialize_with(carrier)
    new(
      carrier: carrier,
      name: carrier.name,
      country: carrier.country_code,
      logo: carrier.logo
    )
  end

  def save
    return false if invalid?

    carrier.attributes = {
      name: name,
      country_code: country
    }

    carrier.logo.attach(logo) if logo.present?
    carrier.save!
  end
end
