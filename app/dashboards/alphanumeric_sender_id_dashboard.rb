require "administrate/base_dashboard"

class AlphanumericSenderIDDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    account: Field::BelongsTo,
    carrier: Field::BelongsTo,
    sender_id: Field::String,
    messaging_services: Field::HasMany,
    status: Field::String.with_options(
      getter: ->(field) {
        field.resource.status.text
      },
    ),
    messages: Field::HasMany,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    account
    status
    sender_id
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    carrier
    sender_id
    messaging_services
    status
    messages
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
