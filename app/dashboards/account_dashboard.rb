require "administrate/base_dashboard"

class AccountDashboard < Administrate::BaseDashboard
  CALL_SESSION_LIMITER = AccountCallSessionLimiter.new

  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    sip_trunk: Field::BelongsTo,
    id: Field::String,
    type: Field::String,
    name: Field::String,
    default_tts_voice: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime,
    status: Field::String,
    calls_per_second: Field::Number,
    current_call_sessions: Field::JSON.with_options(
      getter: ->(field) {
        SomlengRegion::Region.all.each_with_object({}) do |region, result|
          result[region.alias] = CALL_SESSION_LIMITER.session_count_for(region.alias, scope: field.resource.id)
        end
      }
    ),
    allowed_calling_codes: Field::String,
    metadata: Field::JSON.with_options(searchable: false)
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    carrier
    name
    type
    status
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    carrier
    id
    name
    type
    status
    calls_per_second
    current_call_sessions
    default_tts_voice
    sip_trunk
    created_at
    updated_at
    allowed_calling_codes
    metadata
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(account)
    account.name
  end
end
