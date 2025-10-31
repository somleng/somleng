class DestinationGroupForm < ApplicationForm
  attribute :carrier
  attribute :catch_all, :boolean, default: false
  attribute :object, default: -> { DestinationGroup.new }
  attribute :name
  attribute :prefixes, RoutePrefixesType.new, default: []

  validates :name, :prefixes, presence: true, unless: :catch_all
  validate :validate_catch_all

  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "DestinationGroup")
  end

  def self.initialize_with(destination_group)
    new(
      carrier: destination_group.carrier,
      object: destination_group,
      name: destination_group.name,
      catch_all: destination_group.catch_all,
      prefixes: destination_group.prefixes.pluck(:prefix)
    )
  end

  def save
    return false if invalid?

    object.attributes = {
      name:,
      carrier:,
      catch_all:,
      prefixes: (prefixes.map { |prefix| object.prefixes.find_or_initialize_by(prefix:) } unless catch_all)
    }

    object.save!

    true
  end

  def prefixes_formatted
    prefixes.join(", ")
  end

  private

  def validate_catch_all
    return unless carrier.destination_groups.exists?(catch_all: true)

    errors.add(:name, :taken)
  end
end
