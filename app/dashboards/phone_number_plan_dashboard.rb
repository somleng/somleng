require "administrate/base_dashboard"

class PhoneNumberPlanDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    phone_number: Field::BelongsTo,
    carrier: Field::BelongsTo,
    account: Field::BelongsTo,
    canceled_by: Field::BelongsTo,
    id: Field::String,
    number: Field::String,
    amount: Field::String,
    status: Field::String,
    canceled_at: Field::LocalTime,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    carrier
    account
    number
    status
    amount
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    number
    amount
    status
    phone_number
    carrier
    account
    canceled_by
    canceled_at
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(phone_number)
    phone_number.number
  end
end
