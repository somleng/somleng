require "administrate/base_dashboard"

class TariffPlanDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    category: Field::String,
    name: Field::String,
    description: Field::Text,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime,
    tiers: Field::HasMany,
    schedules: Field::HasMany,
    destination_tariffs: Field::HasMany,
    destination_groups: Field::HasMany,
    subscriptions: Field::HasMany,
    accounts: Field::HasMany
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
    tiers
    schedules
    destination_tariffs
    destination_groups
    subscriptions
    accounts
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
