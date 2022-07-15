require "administrate/base_dashboard"

class EventDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    eventable: Field::Polymorphic,
    type: Field::String,
    details: Field::JSON,
    webhook_request_logs: Field::HasMany,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    carrier
    eventable
    type
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    carrier
    eventable
    type
    details
    webhook_request_logs
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
