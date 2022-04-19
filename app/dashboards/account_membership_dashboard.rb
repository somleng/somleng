require "administrate/base_dashboard"

class AccountMembershipDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    user: Field::BelongsTo,
    account: Field::BelongsTo,
    role: Field::String
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    user
    account
    role
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    user
    account
    role
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
