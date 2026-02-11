require "administrate/base_dashboard"

class TariffPackageDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    package_plans: Field::HasMany,
    name: Field::String,
    description: Field::Text,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    carrier
    name
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    carrier
    name
    description
    package_plans
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
