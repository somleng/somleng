require "administrate/base_dashboard"

class TariffPlanTierDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    plan: Field::BelongsTo,
    schedule: Field::BelongsTo,
    weight: Field::Number,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    plan
    schedule
    weight
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    plan
    schedule
    weight
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
