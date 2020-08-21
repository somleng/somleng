class ResourceSerializer < ApplicationSerializer
  def serializable_hash(_options = nil)
    super.merge(
      api_version: ApplicationSerializer::API_VERSION,
      created_at: object.created_at.utc.iso8601,
      updated_at: object.updated_at.utc.iso8601
    )
  end
end
