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

ActiveRecord::Schema[8.1].define(version: 2025_11_04_200509) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"

  create_table "account_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "role", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["account_id", "user_id"], name: "index_account_memberships_on_account_id_and_user_id", unique: true
    t.index ["account_id"], name: "index_account_memberships_on_account_id"
    t.index ["sequence_number"], name: "index_account_memberships_on_sequence_number", unique: true, order: :desc
    t.index ["user_id"], name: "index_account_memberships_on_user_id"
  end

  create_table "account_tariff_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.bigserial "sequence_number", null: false
    t.uuid "tariff_plan_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "category"], name: "index_account_tariff_plans_on_account_id_and_category", unique: true
    t.index ["account_id"], name: "index_account_tariff_plans_on_account_id"
    t.index ["sequence_number"], name: "index_account_tariff_plans_on_sequence_number", unique: true, order: :desc
    t.index ["tariff_plan_id"], name: "index_account_tariff_plans_on_tariff_plan_id"
  end

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "account_memberships_count", default: 0, null: false
    t.string "allowed_calling_codes", default: [], null: false, array: true
    t.string "billing_currency", null: false
    t.integer "calls_per_second", default: 1, null: false
    t.uuid "carrier_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "default_tts_voice", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "name", null: false
    t.bigserial "sequence_number", null: false
    t.uuid "sip_trunk_id"
    t.string "status", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["billing_currency"], name: "index_accounts_on_billing_currency"
    t.index ["carrier_id"], name: "index_accounts_on_carrier_id"
    t.index ["sequence_number"], name: "index_accounts_on_sequence_number", unique: true, order: :desc
    t.index ["sip_trunk_id"], name: "index_accounts_on_sip_trunk_id"
    t.index ["type"], name: "index_accounts_on_type"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.bigserial "sequence_number", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    t.index ["sequence_number"], name: "index_active_storage_attachments_on_sequence_number", unique: true, order: :desc
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.bigserial "sequence_number", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
    t.index ["sequence_number"], name: "index_active_storage_blobs_on_sequence_number", unique: true, order: :desc
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "call_data_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "answer_time", precision: nil
    t.integer "bill_sec", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "direction", null: false
    t.integer "duration_sec", null: false
    t.datetime "end_time", precision: nil, null: false
    t.string "hangup_cause", null: false
    t.uuid "phone_call_id", null: false
    t.bigserial "sequence_number", null: false
    t.string "sip_invite_failure_phrase"
    t.string "sip_invite_failure_status"
    t.string "sip_term_status"
    t.datetime "start_time", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["phone_call_id"], name: "index_call_data_records_on_phone_call_id", unique: true
    t.index ["sequence_number"], name: "index_call_data_records_on_sequence_number", unique: true, order: :desc
    t.index ["sip_invite_failure_status"], name: "index_call_data_records_on_sip_invite_failure_status"
    t.index ["sip_term_status"], name: "index_call_data_records_on_sip_term_status"
  end

  create_table "carriers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "billing_currency", null: false
    t.integer "calls_per_second", default: 0, null: false
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.citext "custom_api_host"
    t.citext "custom_app_host"
    t.text "custom_theme_css"
    t.uuid "default_tariff_bundle_id"
    t.string "name", null: false
    t.boolean "restricted", default: false, null: false
    t.bigserial "sequence_number", null: false
    t.citext "subdomain", null: false
    t.datetime "updated_at", null: false
    t.string "website", null: false
    t.index ["billing_currency"], name: "index_carriers_on_billing_currency"
    t.index ["custom_api_host"], name: "index_carriers_on_custom_api_host", unique: true
    t.index ["custom_app_host"], name: "index_carriers_on_custom_app_host", unique: true
    t.index ["default_tariff_bundle_id"], name: "index_carriers_on_default_tariff_bundle_id"
    t.index ["sequence_number"], name: "index_carriers_on_sequence_number", unique: true, order: :desc
    t.index ["subdomain"], name: "index_carriers_on_subdomain", unique: true
  end

  create_table "destination_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.boolean "catch_all", default: false, null: false
    t.datetime "created_at", null: false
    t.citext "name", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id", "catch_all"], name: "index_destination_groups_on_carrier_id_and_catch_all", unique: true, where: "(catch_all = true)"
    t.index ["carrier_id", "name", "created_at"], name: "index_destination_groups_on_carrier_id_and_name_and_created_at"
    t.index ["carrier_id"], name: "index_destination_groups_on_carrier_id"
    t.index ["sequence_number"], name: "index_destination_groups_on_sequence_number", unique: true, order: :desc
  end

  create_table "destination_prefixes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "destination_group_id", null: false
    t.string "prefix", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_group_id", "prefix"], name: "index_destination_prefixes_on_destination_group_id_and_prefix", unique: true
    t.index ["destination_group_id"], name: "index_destination_prefixes_on_destination_group_id"
    t.index ["sequence_number"], name: "index_destination_prefixes_on_sequence_number", unique: true, order: :desc
  end

  create_table "destination_tariffs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "destination_group_id", null: false
    t.bigserial "sequence_number", null: false
    t.uuid "tariff_id", null: false
    t.uuid "tariff_schedule_id", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_group_id"], name: "index_destination_tariffs_on_destination_group_id"
    t.index ["sequence_number"], name: "index_destination_tariffs_on_sequence_number", unique: true, order: :desc
    t.index ["tariff_id"], name: "index_destination_tariffs_on_tariff_id"
    t.index ["tariff_schedule_id", "destination_group_id"], name: "idx_on_tariff_schedule_id_destination_group_id_42b7112e47", unique: true
    t.index ["tariff_schedule_id", "tariff_id"], name: "index_destination_tariffs_on_tariff_schedule_id_and_tariff_id", unique: true
    t.index ["tariff_schedule_id"], name: "index_destination_tariffs_on_tariff_schedule_id"
  end

  create_table "error_log_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.uuid "error_log_id", null: false
    t.string "message_digest", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["error_log_id"], name: "index_error_log_notifications_on_error_log_id"
    t.index ["message_digest", "user_id"], name: "index_error_log_notifications_on_message_digest_and_user_id"
    t.index ["sequence_number"], name: "index_error_log_notifications_on_sequence_number", unique: true, order: :desc
    t.index ["user_id"], name: "index_error_log_notifications_on_user_id"
  end

  create_table "error_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.uuid "carrier_id"
    t.datetime "created_at", null: false
    t.string "error_message", null: false
    t.bigserial "sequence_number", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_error_logs_on_account_id"
    t.index ["carrier_id"], name: "index_error_logs_on_carrier_id"
    t.index ["sequence_number"], name: "index_error_logs_on_sequence_number", unique: true, order: :desc
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "details", default: {}, null: false
    t.uuid "message_id"
    t.uuid "phone_call_id"
    t.bigserial "sequence_number", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id"], name: "index_events_on_carrier_id"
    t.index ["message_id"], name: "index_events_on_message_id"
    t.index ["phone_call_id"], name: "index_events_on_phone_call_id"
    t.index ["sequence_number"], name: "index_events_on_sequence_number", unique: true, order: :desc
  end

  create_table "exports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "filter_params", default: {}, null: false
    t.string "name", null: false
    t.string "resource_type", null: false
    t.jsonb "scoped_to", default: {}, null: false
    t.bigserial "sequence_number", null: false
    t.string "status_message"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["sequence_number"], name: "index_exports_on_sequence_number", unique: true, order: :desc
    t.index ["user_id"], name: "index_exports_on_user_id"
  end

  create_table "imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.string "error_message"
    t.string "resource_type", null: false
    t.bigserial "sequence_number", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["carrier_id"], name: "index_imports_on_carrier_id"
    t.index ["sequence_number"], name: "index_imports_on_sequence_number", unique: true, order: :desc
    t.index ["user_id"], name: "index_imports_on_user_id"
  end

  create_table "inbound_source_ip_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.inet "ip", null: false
    t.string "region", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.index ["ip"], name: "index_inbound_source_ip_addresses_on_ip", unique: true
    t.index ["sequence_number"], name: "index_inbound_source_ip_addresses_on_sequence_number", unique: true, order: :desc
  end

  create_table "incoming_phone_numbers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "account_type", null: false
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.string "friendly_name", null: false
    t.uuid "messaging_service_id"
    t.string "number", null: false
    t.uuid "phone_number_id"
    t.uuid "phone_number_plan_id", null: false
    t.datetime "released_at"
    t.bigserial "sequence_number", null: false
    t.string "sip_domain"
    t.string "sms_method", null: false
    t.string "sms_url"
    t.string "status", null: false
    t.string "status_callback_method", null: false
    t.string "status_callback_url"
    t.datetime "updated_at", null: false
    t.string "voice_method", null: false
    t.string "voice_url"
    t.index ["account_id"], name: "index_incoming_phone_numbers_on_account_id"
    t.index ["account_type"], name: "index_incoming_phone_numbers_on_account_type"
    t.index ["carrier_id"], name: "index_incoming_phone_numbers_on_carrier_id"
    t.index ["messaging_service_id"], name: "index_incoming_phone_numbers_on_messaging_service_id"
    t.index ["number"], name: "index_incoming_phone_numbers_on_number"
    t.index ["phone_number_id"], name: "index_incoming_phone_numbers_on_phone_number_id"
    t.index ["phone_number_plan_id"], name: "index_incoming_phone_numbers_on_phone_number_plan_id", unique: true
    t.index ["released_at"], name: "index_incoming_phone_numbers_on_released_at"
    t.index ["sequence_number"], name: "index_incoming_phone_numbers_on_sequence_number", unique: true, order: :desc
    t.index ["status", "phone_number_id"], name: "index_incoming_phone_numbers_on_status_and_phone_number_id", unique: true, where: "((status)::text = 'active'::text)"
  end

  create_table "interactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "beneficiary_country_code"
    t.string "beneficiary_fingerprint"
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.string "interactable_type", null: false
    t.uuid "message_id"
    t.uuid "phone_call_id"
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
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

  create_table "media_stream_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "details", default: {}, null: false
    t.uuid "media_stream_id", null: false
    t.uuid "phone_call_id", null: false
    t.bigserial "sequence_number", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["media_stream_id"], name: "index_media_stream_events_on_media_stream_id"
    t.index ["phone_call_id"], name: "index_media_stream_events_on_phone_call_id"
    t.index ["sequence_number"], name: "index_media_stream_events_on_sequence_number", unique: true, order: :desc
  end

  create_table "media_streams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "custom_parameters", default: {}, null: false
    t.uuid "phone_call_id", null: false
    t.bigserial "sequence_number", null: false
    t.string "status", null: false
    t.string "tracks", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["account_id"], name: "index_media_streams_on_account_id"
    t.index ["phone_call_id"], name: "index_media_streams_on_phone_call_id"
    t.index ["sequence_number"], name: "index_media_streams_on_sequence_number", unique: true, order: :desc
  end

  create_table "message_send_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "message_id"
    t.bigserial "sequence_number", null: false
    t.uuid "sms_gateway_id", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_message_send_requests_on_message_id", unique: true
    t.index ["sequence_number"], name: "index_message_send_requests_on_sequence_number", unique: true, order: :desc
    t.index ["sms_gateway_id"], name: "index_message_send_requests_on_sms_gateway_id"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "accepted_at"
    t.uuid "account_id", null: false
    t.string "beneficiary_country_code"
    t.string "beneficiary_fingerprint"
    t.text "body", null: false
    t.datetime "canceled_at"
    t.uuid "carrier_id", null: false
    t.integer "channel"
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.string "direction", null: false
    t.string "encoding", null: false
    t.string "error_code"
    t.string "error_message"
    t.datetime "failed_at"
    t.string "from"
    t.uuid "incoming_phone_number_id"
    t.boolean "internal", default: false, null: false
    t.uuid "messaging_service_id"
    t.uuid "phone_number_id"
    t.decimal "price", precision: 10, scale: 4
    t.string "price_unit"
    t.datetime "queued_at"
    t.datetime "received_at"
    t.datetime "scheduled_at"
    t.integer "segments", null: false
    t.datetime "send_at"
    t.datetime "sending_at"
    t.datetime "sent_at"
    t.bigserial "sequence_number", null: false
    t.boolean "smart_encoded", default: false, null: false
    t.uuid "sms_gateway_id"
    t.string "sms_method"
    t.string "sms_url"
    t.string "status", null: false
    t.string "status_callback_url"
    t.string "to", null: false
    t.datetime "updated_at", null: false
    t.integer "validity_period"
    t.index ["account_id"], name: "index_messages_on_account_id"
    t.index ["carrier_id"], name: "index_messages_on_carrier_id"
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["incoming_phone_number_id"], name: "index_messages_on_incoming_phone_number_id"
    t.index ["internal"], name: "index_messages_on_internal"
    t.index ["messaging_service_id"], name: "index_messages_on_messaging_service_id"
    t.index ["phone_number_id"], name: "index_messages_on_phone_number_id"
    t.index ["sequence_number"], name: "index_messages_on_sequence_number", unique: true, order: :desc
    t.index ["sms_gateway_id"], name: "index_messages_on_sms_gateway_id"
    t.index ["status", "sending_at"], name: "index_messages_on_status_and_sending_at", where: "((status)::text = 'sending'::text)"
  end

  create_table "messaging_services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.string "inbound_message_behavior", null: false
    t.string "inbound_request_method"
    t.string "inbound_request_url"
    t.string "name", null: false
    t.bigserial "sequence_number", null: false
    t.boolean "smart_encoding", default: false, null: false
    t.string "status_callback_url"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_messaging_services_on_account_id"
    t.index ["carrier_id"], name: "index_messaging_services_on_carrier_id"
    t.index ["sequence_number"], name: "index_messaging_services_on_sequence_number", unique: true, order: :desc
  end

  create_table "oauth_access_grants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "application_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.uuid "resource_owner_id", null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.bigserial "sequence_number", null: false
    t.string "token", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["sequence_number"], name: "index_oauth_access_grants_on_sequence_number", unique: true, order: :desc
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "application_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "expires_in"
    t.string "refresh_token"
    t.uuid "resource_owner_id"
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.bigserial "sequence_number", null: false
    t.string "token", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["sequence_number"], name: "index_oauth_access_tokens_on_sequence_number", unique: true, order: :desc
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.uuid "owner_id", null: false
    t.string "owner_type", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.string "secret", null: false
    t.bigserial "sequence_number", null: false
    t.string "uid", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["sequence_number"], name: "index_oauth_applications_on_sequence_number", unique: true, order: :desc
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.bigint "calls"
    t.datetime "captured_at", precision: nil
    t.text "database"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.text "user"
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "pghero_space_stats", force: :cascade do |t|
    t.datetime "captured_at", precision: nil
    t.text "database"
    t.text "relation"
    t.text "schema"
    t.bigint "size"
    t.index ["database", "captured_at"], name: "index_pghero_space_stats_on_database_and_captured_at"
  end

  create_table "phone_call_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.json "params", default: {}, null: false
    t.uuid "phone_call_id", null: false
    t.bigserial "sequence_number", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["phone_call_id"], name: "index_phone_call_events_on_phone_call_id"
    t.index ["sequence_number"], name: "index_phone_call_events_on_sequence_number", unique: true, order: :desc
  end

  create_table "phone_calls", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "beneficiary_country_code"
    t.string "beneficiary_fingerprint"
    t.inet "call_service_host"
    t.string "caller_id"
    t.uuid "carrier_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "direction", null: false
    t.string "external_id"
    t.string "from", null: false
    t.uuid "incoming_phone_number_id"
    t.datetime "initiated_at"
    t.datetime "initiating_at"
    t.datetime "initiation_queued_at"
    t.boolean "internal", default: false, null: false
    t.uuid "parent_call_id"
    t.uuid "phone_number_id"
    t.decimal "price", precision: 10, scale: 4
    t.string "price_unit"
    t.string "region"
    t.bigserial "sequence_number", null: false
    t.uuid "sip_trunk_id"
    t.string "status", null: false
    t.string "status_callback_method"
    t.string "status_callback_url"
    t.string "to", null: false
    t.text "twiml"
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "user_terminated_at"
    t.datetime "user_updated_at"
    t.json "variables", default: {}, null: false
    t.string "voice_method"
    t.string "voice_url"
    t.index ["account_id", "created_at"], name: "index_phone_calls_on_account_id_and_created_at"
    t.index ["account_id", "id"], name: "index_phone_calls_on_account_id_and_id"
    t.index ["account_id", "internal", "sequence_number"], name: "idx_on_account_id_internal_sequence_number_918b5ff8f4", order: { sequence_number: :desc }
    t.index ["account_id", "status"], name: "index_phone_calls_on_account_id_and_status"
    t.index ["account_id"], name: "index_phone_calls_on_account_id"
    t.index ["beneficiary_country_code"], name: "index_phone_calls_on_beneficiary_country_code"
    t.index ["beneficiary_fingerprint"], name: "index_phone_calls_on_beneficiary_fingerprint"
    t.index ["carrier_id"], name: "index_phone_calls_on_carrier_id"
    t.index ["created_at"], name: "index_phone_calls_on_created_at"
    t.index ["direction"], name: "index_phone_calls_on_direction"
    t.index ["external_id"], name: "index_phone_calls_on_external_id", unique: true
    t.index ["from"], name: "index_phone_calls_on_from"
    t.index ["incoming_phone_number_id"], name: "index_phone_calls_on_incoming_phone_number_id"
    t.index ["initiated_at"], name: "index_phone_calls_on_initiated_at"
    t.index ["initiating_at"], name: "index_phone_calls_on_initiating_at"
    t.index ["internal"], name: "index_phone_calls_on_internal"
    t.index ["parent_call_id"], name: "index_phone_calls_on_parent_call_id"
    t.index ["phone_number_id"], name: "index_phone_calls_on_phone_number_id"
    t.index ["sequence_number"], name: "index_phone_calls_on_sequence_number", unique: true, order: :desc
    t.index ["sip_trunk_id", "status", "created_at"], name: "index_phone_calls_on_sip_trunk_id_and_status_and_created_at"
    t.index ["sip_trunk_id", "status"], name: "index_phone_calls_on_sip_trunk_id_and_status"
    t.index ["sip_trunk_id"], name: "index_phone_calls_on_sip_trunk_id"
    t.index ["status", "created_at", "initiation_queued_at"], name: "idx_on_status_created_at_initiation_queued_at_5db44fb542", where: "((status)::text = 'queued'::text)"
    t.index ["status", "created_at"], name: "index_phone_calls_on_status_and_created_at"
    t.index ["status", "initiated_at"], name: "index_phone_calls_on_status_and_initiated_at"
    t.index ["status", "initiating_at"], name: "index_phone_calls_on_status_and_initiating_at"
    t.index ["status", "region"], name: "index_phone_calls_on_status_and_region"
    t.index ["status"], name: "index_phone_calls_on_status"
    t.index ["to"], name: "index_phone_calls_on_to"
    t.index ["user_terminated_at"], name: "index_phone_calls_on_user_terminated_at"
    t.index ["user_updated_at"], name: "index_phone_calls_on_user_updated_at"
  end

  create_table "phone_number_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.integer "amount_cents", null: false
    t.datetime "canceled_at"
    t.uuid "carrier_id"
    t.datetime "created_at", null: false
    t.string "currency", null: false
    t.string "number", null: false
    t.uuid "phone_number_id"
    t.bigserial "sequence_number", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_phone_number_plans_on_account_id"
    t.index ["amount_cents", "currency"], name: "index_phone_number_plans_on_amount_cents_and_currency"
    t.index ["canceled_at"], name: "index_phone_number_plans_on_canceled_at"
    t.index ["carrier_id"], name: "index_phone_number_plans_on_carrier_id"
    t.index ["number"], name: "index_phone_number_plans_on_number"
    t.index ["phone_number_id", "status"], name: "index_phone_number_plans_on_phone_number_id_and_status", unique: true, where: "((status)::text = 'active'::text)"
    t.index ["phone_number_id"], name: "index_phone_number_plans_on_phone_number_id"
    t.index ["sequence_number"], name: "index_phone_number_plans_on_sequence_number", unique: true, order: :desc
    t.index ["status"], name: "index_phone_number_plans_on_status"
  end

  create_table "phone_numbers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "area_code"
    t.uuid "carrier_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "currency", null: false
    t.string "iso_country_code", null: false
    t.citext "iso_region_code"
    t.string "lata"
    t.decimal "latitude", precision: 10, scale: 6
    t.citext "locality"
    t.decimal "longitude", precision: 10, scale: 6
    t.jsonb "metadata", default: {}, null: false
    t.string "number", null: false
    t.integer "price_cents", null: false
    t.citext "rate_center"
    t.bigserial "sequence_number", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "visibility", null: false
    t.index ["area_code"], name: "index_phone_numbers_on_area_code"
    t.index ["carrier_id"], name: "index_phone_numbers_on_carrier_id"
    t.index ["iso_country_code"], name: "index_phone_numbers_on_iso_country_code"
    t.index ["iso_region_code"], name: "index_phone_numbers_on_iso_region_code"
    t.index ["lata"], name: "index_phone_numbers_on_lata"
    t.index ["latitude", "longitude"], name: "index_phone_numbers_on_latitude_and_longitude"
    t.index ["locality"], name: "index_phone_numbers_on_locality"
    t.index ["metadata"], name: "index_phone_numbers_on_metadata", using: :gin
    t.index ["number", "carrier_id"], name: "index_phone_numbers_on_number_and_carrier_id", unique: true
    t.index ["number"], name: "index_phone_numbers_on_number"
    t.index ["price_cents", "currency"], name: "index_phone_numbers_on_price_cents_and_currency"
    t.index ["rate_center"], name: "index_phone_numbers_on_rate_center"
    t.index ["sequence_number"], name: "index_phone_numbers_on_sequence_number", unique: true, order: :desc
    t.index ["type"], name: "index_phone_numbers_on_type"
    t.index ["visibility"], name: "index_phone_numbers_on_visibility"
  end

  create_table "recordings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "external_id"
    t.uuid "phone_call_id", null: false
    t.string "raw_recording_url"
    t.bigserial "sequence_number", null: false
    t.string "status", null: false
    t.string "status_callback_method"
    t.text "status_callback_url"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_recordings_on_account_id"
    t.index ["phone_call_id"], name: "index_recordings_on_phone_call_id"
    t.index ["sequence_number"], name: "index_recordings_on_sequence_number", unique: true, order: :desc
  end

  create_table "sip_trunk_inbound_source_ip_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.uuid "inbound_source_ip_address_id", null: false
    t.inet "ip", null: false
    t.string "region", null: false
    t.bigserial "sequence_number", null: false
    t.uuid "sip_trunk_id", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id"], name: "index_sip_trunk_inbound_source_ip_addresses_on_carrier_id"
    t.index ["ip"], name: "index_sip_trunk_inbound_source_ip_addresses_on_ip"
    t.index ["sequence_number"], name: "index_sip_trunk_inbound_source_ip_addresses_on_sequence_number", unique: true, order: :desc
    t.index ["sip_trunk_id", "inbound_source_ip_address_id"], name: "idx_on_sip_trunk_id_inbound_source_ip_address_id_0d96412c08", unique: true
  end

  create_table "sip_trunks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "authentication_mode", null: false
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.string "default_sender"
    t.string "inbound_country_code"
    t.integer "max_channels"
    t.string "name", null: false
    t.string "outbound_dial_string_prefix"
    t.string "outbound_host"
    t.boolean "outbound_national_dialing", default: false, null: false
    t.boolean "outbound_plus_prefix", default: false, null: false
    t.string "outbound_route_prefixes", default: [], null: false, array: true
    t.string "password"
    t.string "region", null: false
    t.bigserial "sequence_number", null: false
    t.string "sip_profile", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["carrier_id"], name: "index_sip_trunks_on_carrier_id"
    t.index ["default_sender"], name: "index_sip_trunks_on_default_sender"
    t.index ["region"], name: "index_sip_trunks_on_region"
    t.index ["sequence_number"], name: "index_sip_trunks_on_sequence_number", unique: true, order: :desc
    t.index ["sip_profile"], name: "index_sip_trunks_on_sip_profile"
    t.index ["username"], name: "index_sip_trunks_on_username", unique: true
  end

  create_table "sms_gateway_channel_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "route_prefixes", default: [], null: false, array: true
    t.bigserial "sequence_number", null: false
    t.uuid "sms_gateway_id", null: false
    t.datetime "updated_at", null: false
    t.index ["sequence_number"], name: "index_sms_gateway_channel_groups_on_sequence_number", unique: true, order: :desc
    t.index ["sms_gateway_id"], name: "index_sms_gateway_channel_groups_on_sms_gateway_id"
  end

  create_table "sms_gateway_channels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "channel_group_id", null: false
    t.datetime "created_at", null: false
    t.bigserial "sequence_number", null: false
    t.integer "slot_index", limit: 2, null: false
    t.uuid "sms_gateway_id", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_group_id"], name: "index_sms_gateway_channels_on_channel_group_id"
    t.index ["sequence_number"], name: "index_sms_gateway_channels_on_sequence_number", unique: true, order: :desc
    t.index ["slot_index", "sms_gateway_id"], name: "index_sms_gateway_channels_on_slot_index_and_sms_gateway_id", unique: true
    t.index ["sms_gateway_id"], name: "index_sms_gateway_channels_on_sms_gateway_id"
  end

  create_table "sms_gateways", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.string "default_sender"
    t.string "device_token", null: false
    t.datetime "last_connected_at"
    t.integer "max_channels", limit: 2
    t.string "name", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id"], name: "index_sms_gateways_on_carrier_id"
    t.index ["default_sender"], name: "index_sms_gateways_on_default_sender"
    t.index ["device_token"], name: "index_sms_gateways_on_device_token", unique: true
    t.index ["last_connected_at"], name: "index_sms_gateways_on_last_connected_at"
    t.index ["sequence_number"], name: "index_sms_gateways_on_sequence_number", unique: true, order: :desc
  end

  create_table "tariff_bundle_line_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.bigserial "sequence_number", null: false
    t.uuid "tariff_bundle_id", null: false
    t.uuid "tariff_plan_id", null: false
    t.datetime "updated_at", null: false
    t.index ["sequence_number"], name: "index_tariff_bundle_line_items_on_sequence_number", unique: true, order: :desc
    t.index ["tariff_bundle_id", "category"], name: "idx_on_tariff_bundle_id_category_1522bdcbb7", unique: true
    t.index ["tariff_bundle_id"], name: "index_tariff_bundle_line_items_on_tariff_bundle_id"
    t.index ["tariff_plan_id"], name: "index_tariff_bundle_line_items_on_tariff_plan_id"
  end

  create_table "tariff_bundles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.citext "name", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id", "name"], name: "index_tariff_bundles_on_carrier_id_and_name", unique: true
    t.index ["carrier_id"], name: "index_tariff_bundles_on_carrier_id"
    t.index ["sequence_number"], name: "index_tariff_bundles_on_sequence_number", unique: true, order: :desc
  end

  create_table "tariff_plan_tiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigserial "sequence_number", null: false
    t.uuid "tariff_plan_id", null: false
    t.uuid "tariff_schedule_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 8, scale: 2, null: false
    t.index ["sequence_number"], name: "index_tariff_plan_tiers_on_sequence_number", unique: true, order: :desc
    t.index ["tariff_plan_id", "tariff_schedule_id"], name: "idx_on_tariff_plan_id_tariff_schedule_id_aca8d49ee8", unique: true
    t.index ["tariff_plan_id", "weight"], name: "index_tariff_plan_tiers_on_tariff_plan_id_and_weight", unique: true
  end

  create_table "tariff_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.citext "name", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id", "category", "name"], name: "index_tariff_plans_on_carrier_id_and_category_and_name", unique: true
    t.index ["carrier_id"], name: "index_tariff_plans_on_carrier_id"
    t.index ["sequence_number"], name: "index_tariff_plans_on_sequence_number", unique: true, order: :desc
  end

  create_table "tariff_schedules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.citext "name", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id", "category", "name"], name: "index_tariff_schedules_on_carrier_id_and_category_and_name", unique: true
    t.index ["carrier_id"], name: "index_tariff_schedules_on_carrier_id"
    t.index ["sequence_number"], name: "index_tariff_schedules_on_sequence_number", unique: true, order: :desc
  end

  create_table "tariffs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "currency", null: false
    t.decimal "rate_cents", precision: 10, scale: 4, default: "0.0", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id"], name: "index_tariffs_on_carrier_id"
    t.index ["sequence_number"], name: "index_tariffs_on_sequence_number", unique: true, order: :desc
  end

  create_table "trial_interactions_credit_vouchers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.integer "number_of_interactions", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.datetime "valid_at", null: false
    t.index ["carrier_id"], name: "index_trial_interactions_credit_vouchers_on_carrier_id"
    t.index ["sequence_number"], name: "index_trial_interactions_credit_vouchers_on_sequence_number", unique: true, order: :desc
    t.index ["valid_at"], name: "index_trial_interactions_credit_vouchers_on_valid_at"
  end

  create_table "tts_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.integer "num_chars", null: false
    t.uuid "phone_call_id"
    t.bigserial "sequence_number", null: false
    t.string "tts_engine", null: false
    t.string "tts_provider", null: false
    t.string "tts_voice", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_tts_events_on_account_id"
    t.index ["carrier_id"], name: "index_tts_events_on_carrier_id"
    t.index ["created_at"], name: "index_tts_events_on_created_at"
    t.index ["phone_call_id"], name: "index_tts_events_on_phone_call_id"
    t.index ["sequence_number"], name: "index_tts_events_on_sequence_number", unique: true, order: :desc
    t.index ["tts_engine"], name: "index_tts_events_on_tts_engine"
    t.index ["tts_provider"], name: "index_tts_events_on_tts_provider"
    t.index ["tts_voice"], name: "index_tts_events_on_tts_voice"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.string "carrier_role"
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.integer "consumed_timestep"
    t.datetime "created_at", null: false
    t.uuid "current_account_membership_id"
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.uuid "invited_by_id"
    t.string "invited_by_type"
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "name", null: false
    t.boolean "otp_required_for_login"
    t.text "otp_secret"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.bigserial "sequence_number", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "subscribed_notification_topics", default: [], null: false, array: true
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["carrier_id"], name: "index_users_on_carrier_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["current_account_membership_id"], name: "index_users_on_current_account_membership_id"
    t.index ["email", "carrier_id"], name: "index_users_on_email_and_carrier_id", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["sequence_number"], name: "index_users_on_sequence_number", unique: true, order: :desc
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "verification_attempts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.uuid "verification_id", null: false
    t.index ["sequence_number"], name: "index_verification_attempts_on_sequence_number", unique: true, order: :desc
    t.index ["verification_id"], name: "index_verification_attempts_on_verification_id"
  end

  create_table "verification_delivery_attempts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "channel", null: false
    t.datetime "created_at", null: false
    t.string "from", null: false
    t.uuid "message_id"
    t.uuid "phone_call_id"
    t.bigserial "sequence_number", null: false
    t.string "to", null: false
    t.datetime "updated_at", null: false
    t.uuid "verification_id", null: false
    t.index ["message_id"], name: "index_verification_delivery_attempts_on_message_id"
    t.index ["phone_call_id"], name: "index_verification_delivery_attempts_on_phone_call_id"
    t.index ["sequence_number"], name: "index_verification_delivery_attempts_on_sequence_number", unique: true, order: :desc
    t.index ["verification_id"], name: "index_verification_delivery_attempts_on_verification_id"
  end

  create_table "verification_services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "carrier_id", null: false
    t.integer "code_length", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_verification_services_on_account_id"
    t.index ["carrier_id"], name: "index_verification_services_on_carrier_id"
    t.index ["sequence_number"], name: "index_verification_services_on_sequence_number", unique: true, order: :desc
  end

  create_table "verifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.datetime "approved_at"
    t.datetime "canceled_at"
    t.uuid "carrier_id", null: false
    t.string "channel", null: false
    t.string "code", null: false
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.integer "delivery_attempts_count", default: 0, null: false
    t.datetime "expired_at", null: false
    t.string "locale", null: false
    t.bigserial "sequence_number", null: false
    t.string "status", null: false
    t.string "to", null: false
    t.datetime "updated_at", null: false
    t.integer "verification_attempts_count", default: 0, null: false
    t.uuid "verification_service_id"
    t.index ["account_id"], name: "index_verifications_on_account_id"
    t.index ["carrier_id"], name: "index_verifications_on_carrier_id"
    t.index ["created_at"], name: "index_verifications_on_created_at"
    t.index ["expired_at"], name: "index_verifications_on_expired_at"
    t.index ["sequence_number"], name: "index_verifications_on_sequence_number", unique: true, order: :desc
    t.index ["status"], name: "index_verifications_on_status"
    t.index ["verification_service_id"], name: "index_verifications_on_verification_service_id"
  end

  create_table "webhook_endpoints", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", default: true, null: false
    t.uuid "oauth_application_id", null: false
    t.bigserial "sequence_number", null: false
    t.string "signing_secret", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["oauth_application_id"], name: "index_webhook_endpoints_on_oauth_application_id"
    t.index ["sequence_number"], name: "index_webhook_endpoints_on_sequence_number", unique: true, order: :desc
  end

  create_table "webhook_request_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.boolean "failed", null: false
    t.string "http_status_code", null: false
    t.jsonb "payload", default: {}, null: false
    t.bigserial "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.uuid "webhook_endpoint_id", null: false
    t.index ["carrier_id"], name: "index_webhook_request_logs_on_carrier_id"
    t.index ["event_id"], name: "index_webhook_request_logs_on_event_id"
    t.index ["sequence_number"], name: "index_webhook_request_logs_on_sequence_number", unique: true, order: :desc
    t.index ["webhook_endpoint_id"], name: "index_webhook_request_logs_on_webhook_endpoint_id"
  end

  add_foreign_key "account_memberships", "accounts", on_delete: :cascade
  add_foreign_key "account_memberships", "users", on_delete: :cascade
  add_foreign_key "account_tariff_plans", "accounts", on_delete: :cascade
  add_foreign_key "account_tariff_plans", "tariff_plans", on_delete: :cascade
  add_foreign_key "accounts", "carriers"
  add_foreign_key "accounts", "sip_trunks", on_delete: :nullify
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "call_data_records", "phone_calls"
  add_foreign_key "carriers", "tariff_bundles", column: "default_tariff_bundle_id", on_delete: :nullify
  add_foreign_key "destination_groups", "carriers", on_delete: :cascade
  add_foreign_key "destination_prefixes", "destination_groups", on_delete: :cascade
  add_foreign_key "destination_tariffs", "destination_groups", on_delete: :cascade
  add_foreign_key "destination_tariffs", "tariff_schedules", on_delete: :cascade
  add_foreign_key "destination_tariffs", "tariffs", on_delete: :cascade
  add_foreign_key "error_log_notifications", "error_logs", on_delete: :cascade
  add_foreign_key "error_log_notifications", "users", on_delete: :cascade
  add_foreign_key "error_logs", "accounts"
  add_foreign_key "error_logs", "carriers"
  add_foreign_key "events", "carriers"
  add_foreign_key "events", "messages", on_delete: :nullify
  add_foreign_key "events", "phone_calls", on_delete: :nullify
  add_foreign_key "exports", "users", on_delete: :cascade
  add_foreign_key "imports", "carriers", on_delete: :cascade
  add_foreign_key "imports", "users", on_delete: :cascade
  add_foreign_key "incoming_phone_numbers", "accounts"
  add_foreign_key "incoming_phone_numbers", "carriers"
  add_foreign_key "incoming_phone_numbers", "messaging_services", on_delete: :nullify
  add_foreign_key "incoming_phone_numbers", "phone_number_plans"
  add_foreign_key "incoming_phone_numbers", "phone_numbers", on_delete: :nullify
  add_foreign_key "interactions", "accounts"
  add_foreign_key "interactions", "carriers"
  add_foreign_key "interactions", "messages", on_delete: :nullify
  add_foreign_key "interactions", "phone_calls", on_delete: :nullify
  add_foreign_key "media_stream_events", "media_streams"
  add_foreign_key "media_stream_events", "phone_calls"
  add_foreign_key "media_streams", "accounts"
  add_foreign_key "media_streams", "phone_calls"
  add_foreign_key "message_send_requests", "messages", on_delete: :nullify
  add_foreign_key "message_send_requests", "sms_gateways", on_delete: :cascade
  add_foreign_key "messages", "accounts"
  add_foreign_key "messages", "carriers"
  add_foreign_key "messages", "incoming_phone_numbers"
  add_foreign_key "messages", "messaging_services", on_delete: :nullify
  add_foreign_key "messages", "phone_numbers", on_delete: :nullify
  add_foreign_key "messages", "sms_gateways", on_delete: :nullify
  add_foreign_key "messaging_services", "accounts", on_delete: :cascade
  add_foreign_key "messaging_services", "carriers", on_delete: :cascade
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id", on_delete: :cascade
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id", on_delete: :cascade
  add_foreign_key "oauth_applications", "carriers", column: "owner_id", on_delete: :cascade
  add_foreign_key "phone_call_events", "phone_calls"
  add_foreign_key "phone_calls", "accounts"
  add_foreign_key "phone_calls", "carriers"
  add_foreign_key "phone_calls", "incoming_phone_numbers"
  add_foreign_key "phone_calls", "phone_calls", column: "parent_call_id", on_delete: :cascade
  add_foreign_key "phone_calls", "phone_numbers", on_delete: :nullify
  add_foreign_key "phone_calls", "sip_trunks", on_delete: :nullify
  add_foreign_key "phone_number_plans", "accounts"
  add_foreign_key "phone_number_plans", "carriers"
  add_foreign_key "phone_number_plans", "phone_numbers", on_delete: :nullify
  add_foreign_key "phone_numbers", "carriers"
  add_foreign_key "recordings", "accounts"
  add_foreign_key "recordings", "phone_calls"
  add_foreign_key "sip_trunk_inbound_source_ip_addresses", "carriers", on_delete: :cascade
  add_foreign_key "sip_trunk_inbound_source_ip_addresses", "inbound_source_ip_addresses", on_delete: :cascade
  add_foreign_key "sip_trunk_inbound_source_ip_addresses", "sip_trunks", on_delete: :cascade
  add_foreign_key "sip_trunks", "carriers"
  add_foreign_key "sms_gateway_channel_groups", "sms_gateways", on_delete: :cascade
  add_foreign_key "sms_gateway_channels", "sms_gateway_channel_groups", column: "channel_group_id", on_delete: :cascade
  add_foreign_key "sms_gateway_channels", "sms_gateways", on_delete: :cascade
  add_foreign_key "sms_gateways", "carriers"
  add_foreign_key "tariff_bundle_line_items", "tariff_bundles", on_delete: :cascade
  add_foreign_key "tariff_bundle_line_items", "tariff_plans", on_delete: :cascade
  add_foreign_key "tariff_bundles", "carriers", on_delete: :cascade
  add_foreign_key "tariff_plan_tiers", "tariff_plans", on_delete: :cascade
  add_foreign_key "tariff_plan_tiers", "tariff_schedules", on_delete: :cascade
  add_foreign_key "tariff_plans", "carriers", on_delete: :cascade
  add_foreign_key "tariff_schedules", "carriers", on_delete: :cascade
  add_foreign_key "tariffs", "carriers", on_delete: :cascade
  add_foreign_key "trial_interactions_credit_vouchers", "carriers", on_delete: :cascade
  add_foreign_key "tts_events", "accounts", on_delete: :nullify
  add_foreign_key "tts_events", "carriers"
  add_foreign_key "tts_events", "phone_calls", on_delete: :nullify
  add_foreign_key "users", "account_memberships", column: "current_account_membership_id", on_delete: :nullify
  add_foreign_key "users", "carriers"
  add_foreign_key "verification_attempts", "verifications", on_delete: :cascade
  add_foreign_key "verification_delivery_attempts", "messages", on_delete: :nullify
  add_foreign_key "verification_delivery_attempts", "phone_calls", on_delete: :nullify
  add_foreign_key "verification_delivery_attempts", "verifications", on_delete: :cascade
  add_foreign_key "verification_services", "accounts", on_delete: :cascade
  add_foreign_key "verification_services", "carriers", on_delete: :cascade
  add_foreign_key "verifications", "accounts", on_delete: :nullify
  add_foreign_key "verifications", "carriers"
  add_foreign_key "verifications", "verification_services", on_delete: :nullify
  add_foreign_key "webhook_endpoints", "oauth_applications"
  add_foreign_key "webhook_request_logs", "carriers"
  add_foreign_key "webhook_request_logs", "events"
  add_foreign_key "webhook_request_logs", "webhook_endpoints"
end
