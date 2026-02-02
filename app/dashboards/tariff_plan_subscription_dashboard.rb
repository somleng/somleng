require "administrate/base_dashboard"

class TariffPlanSubscriptionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    account: Field::BelongsTo,
    category: Field::String,
    plan: Field::BelongsTo,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    account
    plan
    category
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    plan
    category
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
