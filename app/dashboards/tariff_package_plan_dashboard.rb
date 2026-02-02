require "administrate/base_dashboard"

class TariffPackagePlanDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    package: Field::BelongsTo,
    plan: Field::BelongsTo,
    category: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    category
    package
    plan
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    category
    package
    plan
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
