class UpdateDestinationGroup < UpdateRatingEngineResource
  def initialize(*, **)
    super(*, action: ->(resource, client) { client.upsert_destination_group(resource) }, **)
  end
end
