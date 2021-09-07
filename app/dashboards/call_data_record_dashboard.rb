require "administrate/base_dashboard"

class CallDataRecordDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    phone_call: Field::BelongsTo,
    id: Field::String,
    file: Field::ActiveStorage.with_options(export: false),
    bill_sec: Field::Number,
    duration_sec: Field::Number,
    direction: Field::String,
    hangup_cause: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    start_time: Field::DateTime,
    end_time: Field::DateTime,
    answer_time: Field::DateTime,
    sip_term_status: Field::String,
    sip_invite_failure_status: Field::String,
    sip_invite_failure_phrase: Field::String,
    call_leg: Field::String
  }.freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    phone_call
    id
    file
    bill_sec
    duration_sec
    direction
    hangup_cause
    start_time
    end_time
    answer_time
    sip_term_status
    sip_invite_failure_status
    sip_invite_failure_phrase
    call_leg
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
