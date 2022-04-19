require "administrate/base_dashboard"

class PhoneNumberConfigurationDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    phone_number: Field::BelongsTo,
    voice_url: Field::String,
    voice_method: Field::String,
    status_callback_url: Field::String,
    status_callback_method: Field::String,
    sip_domain: Field::String
  }.freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    phone_number
    voice_url
    voice_method
    status_callback_url
    status_callback_method
    sip_domain
  ].freeze
end
