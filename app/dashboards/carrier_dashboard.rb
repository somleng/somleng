require "administrate/base_dashboard"

class CarrierDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    accounts: Field::HasMany,
    sip_trunks: Field::HasMany,
    phone_numbers: Field::HasMany,
    phone_calls: Field::HasMany.with_options(sort_by: :sequence_number, direction: :desc),
    messages: Field::HasMany.with_options(sort_by: :sequence_number, direction: :desc),
    sms_gateways: Field::HasMany,
    carrier_users: Field::HasMany,
    account_users: Field::HasMany,
    logo: Field::ActiveStorage.with_options(show_preview_size: [ 150, 150 ], export: false),
    favicon: Field::ActiveStorage.with_options(show_display_preview: false, export: false),
    id: Field::String,
    name: Field::String,
    calls_per_second: Field::Number,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime,
    country_code: Field::String,
    subdomain: Field::String,
    website: Field::String,
    custom_app_host: Field::String,
    custom_api_host: Field::String,
    billing_enabled: Field::Boolean,
    billing_currency: Field::String,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    country_code
    accounts
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    logo
    favicon
    country_code
    website
    subdomain
    custom_app_host
    custom_api_host
    created_at
    updated_at
    accounts
    sip_trunks
    sms_gateways
    phone_numbers
    messages
    phone_calls
    carrier_users
    account_users
    billing_enabled
    billing_currency
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(carrier)
    carrier.name
  end
end
