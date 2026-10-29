require "administrate/base_dashboard"

class SIPTrunkDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    caller_id: Field::String,
    caller_id_behavior: Field::String.with_options(
      getter: ->(field) {
        field.resource.caller_id_behavior.text
      }
    ),
    name: Field::String,
    region: Field::String,
    max_channels: Field::String,
    inbound_country_code: Field::String,
    inbound_source_ips: Field::String.with_options(searchable: false),
    outbound_host: Field::String,
    outbound_route_prefixes: Field::String,
    outbound_dial_string_prefix: Field::String,
    outbound_national_dialing: Field::Boolean,
    outbound_plus_prefix: Field::Boolean,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    region
    outbound_host
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    carrier
    id
    name
    region
    max_channels
    inbound_source_ips
    inbound_country_code
    outbound_host
    outbound_route_prefixes
    outbound_dial_string_prefix
    outbound_national_dialing
    outbound_plus_prefix
    caller_id
    caller_id_behavior
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
