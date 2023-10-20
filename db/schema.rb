# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_10_20_123344) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "account_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "user_id", null: false
    t.string "role", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "user_id"], name: "index_account_memberships_on_account_id_and_user_id", unique: true
    t.index ["account_id"], name: "index_account_memberships_on_account_id"
    t.index ["sequence_number"], name: "index_account_memberships_on_sequence_number", unique: true, order: :desc
    t.index ["user_id"], name: "index_account_memberships_on_user_id"
  end

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status", null: false
    t.bigserial "sequence_number", null: false
    t.uuid "carrier_id", null: false
    t.string "allowed_calling_codes", default: [], null: false, array: true
    t.string "name", null: false
    t.integer "account_memberships_count", default: 0, null: false
    t.jsonb "metadata", default: {}, null: false
    t.integer "calls_per_second", default: 1, null: false
    t.uuid "sip_trunk_id"
    t.string "default_tts_voice", null: false
    t.index ["carrier_id"], name: "index_accounts_on_carrier_id"
    t.index ["sequence_number"], name: "index_accounts_on_sequence_number", unique: true, order: :desc
    t.index ["sip_trunk_id"], name: "index_accounts_on_sip_trunk_id"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.bigserial "sequence_number", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    t.index ["sequence_number"], name: "index_active_storage_attachments_on_sequence_number", unique: true, order: :desc
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.bigserial "sequence_number", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
    t.index ["sequence_number"], name: "index_active_storage_blobs_on_sequence_number", unique: true, order: :desc
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "call_data_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "phone_call_id", null: false
    t.integer "bill_sec", null: false
    t.integer "duration_sec", null: false
    t.string "direction", null: false
    t.string "hangup_cause", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "start_time", precision: nil, null: false
    t.datetime "end_time", precision: nil, null: false
    t.datetime "answer_time", precision: nil
    t.string "sip_term_status"
    t.string "sip_invite_failure_status"
    t.string "sip_invite_failure_phrase"
    t.bigserial "sequence_number", null: false
    t.string "call_leg", null: false
    t.index ["phone_call_id"], name: "index_call_data_records_on_phone_call_id"
    t.index ["sequence_number"], name: "index_call_data_records_on_sequence_number", unique: true, order: :desc
  end

  create_table "carriers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country_code", null: false
    t.string "website", null: false
    t.boolean "restricted", default: false, null: false
    t.citext "subdomain", null: false
    t.citext "custom_app_host"
    t.citext "custom_api_host"
    t.text "custom_theme_css"
    t.index ["custom_api_host"], name: "index_carriers_on_custom_api_host", unique: true
    t.index ["custom_app_host"], name: "index_carriers_on_custom_app_host", unique: true
    t.index ["sequence_number"], name: "index_carriers_on_sequence_number", unique: true, order: :desc
    t.index ["subdomain"], name: "index_carriers_on_subdomain", unique: true
  end

  create_table "error_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id"
    t.uuid "account_id"
    t.string "error_message", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_error_logs_on_account_id"
    t.index ["carrier_id"], name: "index_error_logs_on_carrier_id"
    t.index ["sequence_number"], name: "index_error_logs_on_sequence_number", unique: true, order: :desc
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.uuid "phone_call_id"
    t.string "type", null: false
    t.jsonb "details", default: {}, null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "message_id"
    t.index ["carrier_id"], name: "index_events_on_carrier_id"
    t.index ["message_id"], name: "index_events_on_message_id"
    t.index ["phone_call_id"], name: "index_events_on_phone_call_id"
    t.index ["sequence_number"], name: "index_events_on_sequence_number", unique: true, order: :desc
  end

  create_table "exports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.jsonb "filter_params", default: {}, null: false
    t.jsonb "scoped_to", default: {}, null: false
    t.string "name", null: false
    t.string "resource_type", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status_message"
    t.index ["sequence_number"], name: "index_exports_on_sequence_number", unique: true, order: :desc
    t.index ["user_id"], name: "index_exports_on_user_id"
  end

  create_table "imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "resource_type", null: false
    t.string "status", null: false
    t.string "error_message"
    t.uuid "user_id", null: false
    t.uuid "carrier_id", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id"], name: "index_imports_on_carrier_id"
    t.index ["sequence_number"], name: "index_imports_on_sequence_number", unique: true, order: :desc
    t.index ["user_id"], name: "index_imports_on_user_id"
  end

  create_table "interactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "interactable_type", null: false
    t.uuid "phone_call_id"
    t.uuid "carrier_id", null: false
    t.uuid "account_id", null: false
    t.string "beneficiary_fingerprint", null: false
    t.string "beneficiary_country_code", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "message_id"
    t.index ["account_id"], name: "index_interactions_on_account_id"
    t.index ["beneficiary_country_code"], name: "index_interactions_on_beneficiary_country_code"
    t.index ["beneficiary_fingerprint"], name: "index_interactions_on_beneficiary_fingerprint"
    t.index ["carrier_id"], name: "index_interactions_on_carrier_id"
    t.index ["created_at"], name: "index_interactions_on_created_at"
    t.index ["interactable_type"], name: "index_interactions_on_interactable_type"
    t.index ["message_id"], name: "index_interactions_on_message_id", unique: true
    t.index ["phone_call_id"], name: "index_interactions_on_phone_call_id", unique: true
    t.index ["sequence_number"], name: "index_interactions_on_sequence_number", unique: true, order: :desc
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "carrier_id", null: false
    t.uuid "phone_number_id"
    t.uuid "sms_gateway_id"
    t.integer "channel"
    t.text "body", null: false
    t.integer "segments", null: false
    t.string "encoding", null: false
    t.string "to", null: false
    t.string "from"
    t.string "direction", null: false
    t.string "sms_url"
    t.string "sms_method"
    t.string "status", null: false
    t.string "status_callback_url"
    t.string "beneficiary_country_code", null: false
    t.string "beneficiary_fingerprint", null: false
    t.string "error_code"
    t.string "error_message"
    t.datetime "send_at"
    t.datetime "accepted_at"
    t.datetime "queued_at"
    t.datetime "sending_at"
    t.datetime "sent_at"
    t.datetime "failed_at"
    t.datetime "received_at"
    t.datetime "canceled_at"
    t.datetime "scheduled_at"
    t.decimal "price", precision: 10, scale: 4
    t.string "price_unit"
    t.integer "validity_period"
    t.boolean "smart_encoded", default: false, null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "messaging_service_id"
    t.datetime "delivered_at"
    t.index ["account_id"], name: "index_messages_on_account_id"
    t.index ["carrier_id"], name: "index_messages_on_carrier_id"
    t.index ["messaging_service_id"], name: "index_messages_on_messaging_service_id"
    t.index ["phone_number_id"], name: "index_messages_on_phone_number_id"
    t.index ["sequence_number"], name: "index_messages_on_sequence_number", unique: true, order: :desc
    t.index ["sms_gateway_id"], name: "index_messages_on_sms_gateway_id"
  end

  create_table "messaging_services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "carrier_id", null: false
    t.string "name", null: false
    t.string "status_callback_url"
    t.string "inbound_request_url"
    t.string "inbound_request_method"
    t.boolean "smart_encoding", default: false, null: false
    t.string "inbound_message_behavior", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_messaging_services_on_account_id"
    t.index ["carrier_id"], name: "index_messaging_services_on_carrier_id"
    t.index ["sequence_number"], name: "index_messaging_services_on_sequence_number", unique: true, order: :desc
  end

  create_table "oauth_access_grants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_owner_id", null: false
    t.uuid "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.datetime "updated_at", precision: nil, null: false
    t.bigserial "sequence_number", null: false
    t.index ["sequence_number"], name: "index_oauth_access_grants_on_sequence_number", unique: true, order: :desc
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_owner_id"
    t.uuid "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.bigserial "sequence_number", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["sequence_number"], name: "index_oauth_access_tokens_on_sequence_number", unique: true, order: :desc
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.uuid "owner_id", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigserial "sequence_number", null: false
    t.string "owner_type", null: false
    t.boolean "confidential", default: true, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["sequence_number"], name: "index_oauth_applications_on_sequence_number", unique: true, order: :desc
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.text "database"
    t.text "user"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.bigint "calls"
    t.datetime "captured_at", precision: nil
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "pghero_space_stats", force: :cascade do |t|
    t.text "database"
    t.text "schema"
    t.text "relation"
    t.bigint "size"
    t.datetime "captured_at", precision: nil
    t.index ["database", "captured_at"], name: "index_pghero_space_stats_on_database_and_captured_at"
  end

  create_table "phone_call_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "phone_call_id", null: false
    t.json "params", default: {}, null: false
    t.string "type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigserial "sequence_number", null: false
    t.index ["phone_call_id"], name: "index_phone_call_events_on_phone_call_id"
    t.index ["sequence_number"], name: "index_phone_call_events_on_sequence_number", unique: true, order: :desc
  end

  create_table "phone_calls", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "to", null: false
    t.string "from", null: false
    t.string "voice_url"
    t.string "voice_method"
    t.string "status", null: false
    t.string "status_callback_url"
    t.string "status_callback_method"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "external_id"
    t.uuid "phone_number_id"
    t.json "variables", default: {}, null: false
    t.string "direction", null: false
    t.bigserial "sequence_number", null: false
    t.text "twiml"
    t.uuid "carrier_id", null: false
    t.decimal "price", precision: 10, scale: 4
    t.string "price_unit"
    t.string "caller_id"
    t.string "beneficiary_country_code", null: false
    t.string "beneficiary_fingerprint", null: false
    t.uuid "sip_trunk_id"
    t.datetime "initiated_at"
    t.datetime "initiating_at"
    t.index ["account_id", "created_at"], name: "index_phone_calls_on_account_id_and_created_at"
    t.index ["account_id", "id"], name: "index_phone_calls_on_account_id_and_id"
    t.index ["account_id", "status"], name: "index_phone_calls_on_account_id_and_status"
    t.index ["account_id"], name: "index_phone_calls_on_account_id"
    t.index ["beneficiary_country_code"], name: "index_phone_calls_on_beneficiary_country_code"
    t.index ["beneficiary_fingerprint"], name: "index_phone_calls_on_beneficiary_fingerprint"
    t.index ["carrier_id"], name: "index_phone_calls_on_carrier_id"
    t.index ["created_at"], name: "index_phone_calls_on_created_at"
    t.index ["direction"], name: "index_phone_calls_on_direction"
    t.index ["external_id"], name: "index_phone_calls_on_external_id", unique: true
    t.index ["from"], name: "index_phone_calls_on_from"
    t.index ["initiated_at"], name: "index_phone_calls_on_initiated_at"
    t.index ["initiating_at"], name: "index_phone_calls_on_initiating_at"
    t.index ["phone_number_id"], name: "index_phone_calls_on_phone_number_id"
    t.index ["sequence_number"], name: "index_phone_calls_on_sequence_number", unique: true, order: :desc
    t.index ["sip_trunk_id", "status"], name: "index_phone_calls_on_sip_trunk_id_and_status"
    t.index ["sip_trunk_id"], name: "index_phone_calls_on_sip_trunk_id"
    t.index ["status", "created_at"], name: "index_phone_calls_on_status_and_created_at"
    t.index ["status", "initiated_at"], name: "index_phone_calls_on_status_and_initiated_at"
    t.index ["status", "initiating_at"], name: "index_phone_calls_on_status_and_initiating_at"
    t.index ["status"], name: "index_phone_calls_on_status"
    t.index ["to"], name: "index_phone_calls_on_to"
  end

  create_table "phone_number_configurations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "phone_number_id", null: false
    t.string "voice_url"
    t.string "voice_method"
    t.string "status_callback_url"
    t.string "status_callback_method"
    t.string "sip_domain"
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sms_url"
    t.string "sms_method"
    t.uuid "messaging_service_id"
    t.index ["messaging_service_id"], name: "index_phone_number_configurations_on_messaging_service_id"
    t.index ["phone_number_id"], name: "index_phone_number_configurations_on_phone_number_id", unique: true
    t.index ["sequence_number"], name: "index_phone_number_configurations_on_sequence_number", unique: true, order: :desc
  end

  create_table "phone_numbers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.string "number", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigserial "sequence_number", null: false
    t.uuid "carrier_id", null: false
    t.boolean "enabled", default: true, null: false
    t.index ["account_id"], name: "index_phone_numbers_on_account_id"
    t.index ["carrier_id"], name: "index_phone_numbers_on_carrier_id"
    t.index ["enabled"], name: "index_phone_numbers_on_enabled"
    t.index ["number", "carrier_id"], name: "index_phone_numbers_on_number_and_carrier_id", unique: true
    t.index ["number"], name: "index_phone_numbers_on_number"
    t.index ["sequence_number"], name: "index_phone_numbers_on_sequence_number", unique: true, order: :desc
  end

  create_table "recordings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "phone_call_id", null: false
    t.string "status", null: false
    t.string "external_id"
    t.string "raw_recording_url"
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "status_callback_url"
    t.string "status_callback_method"
    t.index ["account_id"], name: "index_recordings_on_account_id"
    t.index ["phone_call_id"], name: "index_recordings_on_phone_call_id"
    t.index ["sequence_number"], name: "index_recordings_on_sequence_number", unique: true, order: :desc
  end

  create_table "sip_trunks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.string "name", null: false
    t.inet "inbound_source_ip"
    t.string "outbound_host"
    t.string "outbound_route_prefixes", default: [], null: false, array: true
    t.string "outbound_dial_string_prefix"
    t.boolean "outbound_national_dialing", default: false, null: false
    t.boolean "outbound_plus_prefix", default: false, null: false
    t.boolean "outbound_symmetric_latching_supported", default: true, null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authentication_mode", null: false
    t.string "username"
    t.string "password"
    t.string "inbound_country_code"
    t.integer "max_channels"
    t.index ["carrier_id"], name: "index_sip_trunks_on_carrier_id"
    t.index ["inbound_source_ip"], name: "index_sip_trunks_on_inbound_source_ip", unique: true
    t.index ["sequence_number"], name: "index_sip_trunks_on_sequence_number", unique: true, order: :desc
    t.index ["username"], name: "index_sip_trunks_on_username", unique: true
  end

  create_table "sms_gateway_channel_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sms_gateway_id", null: false
    t.string "name", null: false
    t.string "route_prefixes", default: [], null: false, array: true
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sequence_number"], name: "index_sms_gateway_channel_groups_on_sequence_number", unique: true, order: :desc
    t.index ["sms_gateway_id"], name: "index_sms_gateway_channel_groups_on_sms_gateway_id"
  end

  create_table "sms_gateway_channels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sms_gateway_id", null: false
    t.uuid "channel_group_id", null: false
    t.integer "slot_index", limit: 2, null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_group_id"], name: "index_sms_gateway_channels_on_channel_group_id"
    t.index ["sequence_number"], name: "index_sms_gateway_channels_on_sequence_number", unique: true, order: :desc
    t.index ["slot_index", "sms_gateway_id"], name: "index_sms_gateway_channels_on_slot_index_and_sms_gateway_id", unique: true
    t.index ["sms_gateway_id"], name: "index_sms_gateway_channels_on_sms_gateway_id"
  end

  create_table "sms_gateways", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.string "name", null: false
    t.integer "max_channels", limit: 2
    t.string "device_token", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id"], name: "index_sms_gateways_on_carrier_id"
    t.index ["device_token"], name: "index_sms_gateways_on_device_token", unique: true
    t.index ["sequence_number"], name: "index_sms_gateways_on_sequence_number", unique: true, order: :desc
  end

  create_table "tts_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.uuid "account_id"
    t.uuid "phone_call_id"
    t.integer "num_chars", null: false
    t.string "tts_voice", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_tts_events_on_account_id"
    t.index ["carrier_id"], name: "index_tts_events_on_carrier_id"
    t.index ["created_at"], name: "index_tts_events_on_created_at"
    t.index ["phone_call_id"], name: "index_tts_events_on_phone_call_id"
    t.index ["sequence_number"], name: "index_tts_events_on_sequence_number", unique: true, order: :desc
    t.index ["tts_voice"], name: "index_tts_events_on_tts_voice"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.string "carrier_role"
    t.string "name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.uuid "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.uuid "current_account_membership_id"
    t.text "otp_secret"
    t.index ["carrier_id"], name: "index_users_on_carrier_id"
    t.index ["current_account_membership_id"], name: "index_users_on_current_account_membership_id"
    t.index ["email", "carrier_id"], name: "index_users_on_email_and_carrier_id", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["sequence_number"], name: "index_users_on_sequence_number", unique: true, order: :desc
  end

  create_table "webhook_endpoints", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "oauth_application_id", null: false
    t.string "url", null: false
    t.string "signing_secret", null: false
    t.boolean "enabled", default: true, null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["oauth_application_id"], name: "index_webhook_endpoints_on_oauth_application_id"
    t.index ["sequence_number"], name: "index_webhook_endpoints_on_sequence_number", unique: true, order: :desc
  end

  create_table "webhook_request_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "event_id", null: false
    t.uuid "webhook_endpoint_id", null: false
    t.string "url", null: false
    t.string "http_status_code", null: false
    t.boolean "failed", null: false
    t.jsonb "payload", default: {}, null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "carrier_id", null: false
    t.index ["carrier_id"], name: "index_webhook_request_logs_on_carrier_id"
    t.index ["event_id"], name: "index_webhook_request_logs_on_event_id"
    t.index ["sequence_number"], name: "index_webhook_request_logs_on_sequence_number", unique: true, order: :desc
    t.index ["webhook_endpoint_id"], name: "index_webhook_request_logs_on_webhook_endpoint_id"
  end

  add_foreign_key "account_memberships", "accounts", on_delete: :cascade
  add_foreign_key "account_memberships", "users", on_delete: :cascade
  add_foreign_key "accounts", "carriers"
  add_foreign_key "accounts", "sip_trunks", on_delete: :nullify
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "call_data_records", "phone_calls"
  add_foreign_key "error_logs", "accounts"
  add_foreign_key "error_logs", "carriers"
  add_foreign_key "events", "carriers"
  add_foreign_key "events", "messages", on_delete: :nullify
  add_foreign_key "events", "phone_calls", on_delete: :nullify
  add_foreign_key "exports", "users"
  add_foreign_key "imports", "carriers", on_delete: :cascade
  add_foreign_key "imports", "users", on_delete: :cascade
  add_foreign_key "interactions", "accounts"
  add_foreign_key "interactions", "carriers"
  add_foreign_key "interactions", "messages", on_delete: :nullify
  add_foreign_key "interactions", "phone_calls", on_delete: :nullify
  add_foreign_key "messages", "accounts"
  add_foreign_key "messages", "carriers"
  add_foreign_key "messages", "messaging_services", on_delete: :nullify
  add_foreign_key "messages", "phone_numbers", on_delete: :nullify
  add_foreign_key "messages", "sms_gateways", on_delete: :nullify
  add_foreign_key "messaging_services", "accounts", on_delete: :cascade
  add_foreign_key "messaging_services", "carriers", on_delete: :cascade
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_applications", "carriers", column: "owner_id"
  add_foreign_key "phone_call_events", "phone_calls"
  add_foreign_key "phone_calls", "accounts"
  add_foreign_key "phone_calls", "carriers"
  add_foreign_key "phone_calls", "phone_numbers", on_delete: :nullify
  add_foreign_key "phone_calls", "sip_trunks", on_delete: :nullify
  add_foreign_key "phone_number_configurations", "messaging_services", on_delete: :nullify
  add_foreign_key "phone_number_configurations", "phone_numbers", on_delete: :cascade
  add_foreign_key "phone_numbers", "accounts"
  add_foreign_key "phone_numbers", "carriers"
  add_foreign_key "recordings", "accounts"
  add_foreign_key "recordings", "phone_calls"
  add_foreign_key "sip_trunks", "carriers"
  add_foreign_key "sms_gateway_channel_groups", "sms_gateways", on_delete: :cascade
  add_foreign_key "sms_gateway_channels", "sms_gateway_channel_groups", column: "channel_group_id", on_delete: :cascade
  add_foreign_key "sms_gateway_channels", "sms_gateways", on_delete: :cascade
  add_foreign_key "sms_gateways", "carriers"
  add_foreign_key "tts_events", "accounts", on_delete: :nullify
  add_foreign_key "tts_events", "carriers"
  add_foreign_key "tts_events", "phone_calls", on_delete: :nullify
  add_foreign_key "users", "account_memberships", column: "current_account_membership_id", on_delete: :nullify
  add_foreign_key "users", "carriers"
  add_foreign_key "webhook_endpoints", "oauth_applications"
  add_foreign_key "webhook_request_logs", "carriers"
  add_foreign_key "webhook_request_logs", "events"
  add_foreign_key "webhook_request_logs", "webhook_endpoints"
end
