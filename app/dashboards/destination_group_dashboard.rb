require "administrate/base_dashboard"

class DestinationGroupDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    catch_all: Field::Boolean,
    name: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
    carrier
    catch_all
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    carrier
    name
    catch_all
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
