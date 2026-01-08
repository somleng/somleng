class UpdateDestinationGroupForm < UpdateRatingEngineResource
  def call
    super do
      client.upsert_destination_group(resource.object)
    end
  end
end
