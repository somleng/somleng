require "administrate/base_dashboard"

# t.string "resource_type", null: false
# t.string "status", null: false
# t.string "error_message"
# t.uuid "user_id", null: false
# t.uuid "carrier_id", null: false
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false

class ImportDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    resource_type: Field::String,
    status: Field::String,
    error_message: Field::String,
    user: Field::BelongsTo,
    carrier: Field::BelongsTo,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    resource_type
    status
    error_message
    user
    carrier
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    resource_type
    status
    error_message
    user
    carrier
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
