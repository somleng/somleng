require "administrate/base_dashboard"

class SIPTrunkDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    id: Field::String,
    name: Field::String,
    inbound_trunk_prefix_replacement: Field::String,
    inbound_source_ip: Field::String.with_options(searchable: false),
    outbound_host: Field::String,
    outbound_route_prefixes: Field::String,
    outbound_dial_string_prefix: Field::String,
    outbound_trunk_prefix: Field::Boolean,
    outbound_plus_prefix: Field::Boolean,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    inbound_source_ip
    outbound_host
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    carrier
    id
    name
    inbound_source_ip
    inbound_trunk_prefix_replacement
    outbound_host
    outbound_route_prefixes
    outbound_dial_string_prefix
    outbound_trunk_prefix
    outbound_plus_prefix
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
