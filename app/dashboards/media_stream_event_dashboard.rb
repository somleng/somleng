require "administrate/base_dashboard"

class MediaStreamEventDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    media_stream: Field::BelongsTo,
    type: Field::String,
    details: Field::JSON,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    type
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    media_stream
    type
    details
    created_at
    updated_at
  ].freeze
end
