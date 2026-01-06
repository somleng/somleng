class DestinationGroupForm < ApplicationForm
  attribute :carrier
  attribute :catch_all, :boolean, default: false
  attribute :object, default: -> { DestinationGroup.new }
  attribute :name
  attribute :prefixes, RoutePrefixesType.new, default: []
  attribute :rating_engine_workflow, default: -> { UpsertRatingEngineResource }

  validates :name, :prefixes, presence: true, unless: :catch_all
  validate :validate_catch_all

  delegate :persisted?, :new_record?, :id, to: :object

  before_validation :set_catch_all

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

    object.carrier = carrier
    object.catch_all = catch_all
    object.name = name
    if catch_all?
      object.name = DestinationGroup::DEFAULT_CATCH_ALL_NAME
      object.prefixes = []
    else
      object.prefixes = prefixes.map { |prefix| object.prefixes.find_or_initialize_by(prefix:) }
    end

    rating_engine_workflow.call(
      object, remote_action: ->(resource, client) {
        client.upsert_destination_group(resource)
      }
    )

    true
  end

  def catch_all?
    !!catch_all
  end

  def prefixes_formatted
    prefixes.join(", ")
  end

  private

  def validate_catch_all
    return unless catch_all?
    return unless carrier.destination_groups.exists?(catch_all: true)

    errors.add(:name, :taken)
  end

  def set_catch_all
    self.catch_all = true if prefixes.sort == DestinationGroup::CATCH_ALL_PREFIXES
  end
end
