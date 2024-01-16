require "administrate/base_dashboard"

class VerificationServiceDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    account: Field::BelongsTo,
    verifications: Field::HasMany,
    name: Field::String,
    code_length: Field::Number,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    account
    carrier
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    code_length
    carrier
    account
    created_at
    updated_at
    verifications
  ].freeze

  def display_resource(verification_service)
    verification_service.name
  end
end
