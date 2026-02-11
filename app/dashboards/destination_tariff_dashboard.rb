require "administrate/base_dashboard"

class DestinationTariffDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    destination_group: Field::BelongsTo,
    schedule: Field::BelongsTo,
    tariff: Field::BelongsTo,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    schedule
    destination_group
    tariff
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    schedule
    destination_group
    tariff
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
