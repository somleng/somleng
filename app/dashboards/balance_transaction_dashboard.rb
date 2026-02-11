require "administrate/base_dashboard"

class BalanceTransactionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    account: Field::BelongsTo,
    created_by: Field::BelongsTo,
    id: Field::String,
    type: Field::String,
    amount: Field::String,
    currency: Field::String,
    description: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    account
    type
    amount
    currency
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    type
    amount
    currency
    description
    created_by
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
