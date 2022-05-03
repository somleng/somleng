require "administrate/base_dashboard"

class InboundSIPTrunkDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    id: Field::String,
    name: Field::String,
    trunk_prefix_replacement: Field::String,
    source_ip: Field::String.with_options(searchable: false),
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    source_ip
    trunk_prefix_replacement
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    carrier
    id
    name
    source_ip
    trunk_prefix_replacement
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
