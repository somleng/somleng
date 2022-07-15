require "administrate/base_dashboard"

class WebhookRequestLogDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    event: Field::BelongsTo,
    carrier: Field::BelongsTo,
    url: Field::String,
    http_status_code: Field::String,
    failed: Field::String,
    payload: Field::JSON,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    carrier
    event
    url
    http_status_code
    failed
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    event
    carrier
    url
    http_status_code
    failed
    payload
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {
    failed: ->(resources) { resources.failed }
  }.freeze
end
