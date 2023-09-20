require "administrate/base_dashboard"

class ExportDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    user: Field::BelongsTo,
    filter_params: Field::JSON.with_options(searchable: false),
    scoped_to: Field::JSON.with_options(searchable: false),
    name: Field::String,
    status_message: Field::String,
    resource_type: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
    status_message
    user
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    resource_type
    status_message
    user
    filter_params
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
