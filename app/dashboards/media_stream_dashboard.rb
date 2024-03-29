require "administrate/base_dashboard"

class MediaStreamDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    phone_call: Field::BelongsTo,
    account: Field::BelongsTo,
    events: Field::HasMany,
    url: Field::String,
    status: Field::String,
    tracks: Field::String,
    custom_parameters: Field::JSON,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    url
    status
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    phone_call
    account
    url
    status
    tracks
    custom_parameters
    events
    created_at
    updated_at
  ].freeze
end
