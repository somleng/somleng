require "administrate/base_dashboard"

class OutboundSIPTrunkDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    id: Field::String,
    name: Field::String,
    host: Field::String,
    route_prefixes: Field::String,
    dial_string_prefix: Field::String,
    trunk_prefix: Field::Boolean,
    plus_prefix: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    host
    trunk_prefix
    plus_prefix
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    carrier
    id
    name
    host
    route_prefixes
    dial_string_prefix
    trunk_prefix
    plus_prefix
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
