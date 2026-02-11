require "administrate/base_dashboard"

class TariffScheduleDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    category: Field::String,
    name: Field::String,
    description: Field::Text,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime,
    destination_tariffs: Field::HasMany,
    plan_tiers: Field::HasMany
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
    carrier
    category
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    carrier
    name
    category
    description
    destination_tariffs
    plan_tiers
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
