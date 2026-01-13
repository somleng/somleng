require "administrate/base_dashboard"

class AccountDashboard < Administrate::BaseDashboard
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
    enqueued_calls: Field::Number.with_options(
      getter: ->(field) {
        OutboundCallsQueue.new(field.resource).size
      }
    ),
    current_call_sessions: Field::JSON.with_options(
      getter: ->(field) {
        SomlengRegion::Region.all.each_with_object({}) do |region, result|
          result[region.alias] = AccountCallSessionLimiter.new.session_count_for(region.alias, scope: field.resource.id)
        end
      }
    ),
    allowed_calling_codes: Field::String,
    metadata: Field::JSON.with_options(searchable: false),
    billing_mode: Field::String,
    billing_currency: Field::String,
    billing_enabled: Field::Boolean
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
    enqueued_calls
    current_call_sessions
    default_tts_voice
    sip_trunk
    billing_enabled
    billing_currency
    billing_mode
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
