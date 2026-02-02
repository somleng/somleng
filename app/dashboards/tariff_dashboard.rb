require "administrate/base_dashboard"

class TariffDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    category: Field::String,
    currency: Field::String,
    rate_cents: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    carrier
    category
    rate_cents
    currency
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    carrier
    category
    rate_cents
    currency
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
