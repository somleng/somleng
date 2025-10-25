class DestinationGroupForm < ApplicationForm
  attribute :carrier
  attribute :object, default: -> { DestinationGroup.new }
  attribute :name
  attribute :prefixes, RoutePrefixesType.new, default: []

  validates :name, :prefixes, presence: true

  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "DestinationGroup")
  end

  def self.initialize_with(destination_group)
    new(
      carrier: destination_group.carrier,
      object: destination_group,
      name: destination_group.name,
      prefixes: destination_group.prefixes.pluck(:prefix)
    )
  end

  def save
    return false if invalid?

    object.attributes = {
      name:,
      carrier:,
      prefixes: prefixes.map { |prefix| object.prefixes.find_or_initialize_by(prefix:) }
    }

    object.save!

    true
  end

  def prefixes_formatted
    prefixes.join(", ")
  end
end
