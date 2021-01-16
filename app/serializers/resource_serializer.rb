class ResourceSerializer < ApplicationSerializer
  def serializable_hash(_options = nil)
    super.merge(
      api_version: ApplicationSerializer::API_VERSION,
      sid: object.id,
      account_sid: object.account_id,
      date_created: format_time(object.created_at),
      date_updated: format_time(object.updated_at)
    )
  end

  private

  def format_time(value)
    return if value.blank?

    value.utc.rfc2822
  end
end
