require "administrate/base_dashboard"

class SIPTrunkDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    default_sender: Field::BelongsTo,
    id: Field::String,
    name: Field::String,
    region: Field::String,
    max_channels: Field::String,
    inbound_country_code: Field::String,
    inbound_source_ip: Field::String.with_options(searchable: false),
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
    inbound_source_ip
    outbound_host
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    carrier
    id
    name
    region
    max_channels
    inbound_source_ip
    inbound_country_code
    outbound_host
    outbound_route_prefixes
    outbound_dial_string_prefix
    outbound_national_dialing
    outbound_plus_prefix
    default_sender
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
