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

ActiveRecord::Schema.define(version: 2022_01_27_082011) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "account_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "user_id", null: false
    t.string "role", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id", "user_id"], name: "index_account_memberships_on_account_id_and_user_id", unique: true
    t.index ["account_id"], name: "index_account_memberships_on_account_id"
    t.index ["sequence_number"], name: "index_account_memberships_on_sequence_number", unique: true, order: :desc
    t.index ["user_id"], name: "index_account_memberships_on_user_id"
  end

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", null: false
    t.bigserial "sequence_number", null: false
    t.uuid "carrier_id", null: false
    t.uuid "outbound_sip_trunk_id"
    t.string "allowed_calling_codes", default: [], null: false, array: true
    t.string "name", null: false
    t.integer "account_memberships_count", default: 0, null: false
    t.jsonb "metadata", default: {}, null: false
    t.index ["carrier_id"], name: "index_accounts_on_carrier_id"
    t.index ["outbound_sip_trunk_id"], name: "index_accounts_on_outbound_sip_trunk_id"
    t.index ["sequence_number"], name: "index_accounts_on_sequence_number", unique: true, order: :desc
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
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
    t.string "checksum", null: false
    t.datetime "created_at", null: false
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
    t.string "file_id"
    t.string "file_filename"
    t.integer "file_size"
    t.string "file_content_type"
    t.integer "bill_sec", null: false
    t.integer "duration_sec", null: false
    t.string "direction", null: false
    t.string "hangup_cause", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.datetime "answer_time"
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "country_code", null: false
    t.index ["sequence_number"], name: "index_carriers_on_sequence_number", unique: true, order: :desc
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.string "eventable_type", null: false
    t.uuid "eventable_id", null: false
    t.string "type", null: false
    t.jsonb "details", default: {}, null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["carrier_id"], name: "index_events_on_carrier_id"
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable"
    t.index ["sequence_number"], name: "index_events_on_sequence_number", unique: true, order: :desc
  end

  create_table "exports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.jsonb "filter_params", default: {}, null: false
    t.jsonb "scoped_to", default: {}, null: false
    t.string "name", null: false
    t.string "resource_type", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sequence_number"], name: "index_exports_on_sequence_number", unique: true, order: :desc
    t.index ["user_id"], name: "index_exports_on_user_id"
  end

  create_table "inbound_sip_trunks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.string "name", null: false
    t.string "trunk_prefix_replacement"
    t.inet "source_ip", null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["carrier_id"], name: "index_inbound_sip_trunks_on_carrier_id"
    t.index ["sequence_number"], name: "index_inbound_sip_trunks_on_sequence_number", unique: true, order: :desc
    t.index ["source_ip"], name: "index_inbound_sip_trunks_on_source_ip", unique: true
  end

  create_table "oauth_access_grants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_owner_id", null: false
    t.uuid "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.datetime "updated_at", null: false
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
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigserial "sequence_number", null: false
    t.string "owner_type", null: false
    t.boolean "confidential", default: true, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["sequence_number"], name: "index_oauth_applications_on_sequence_number", unique: true, order: :desc
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "outbound_sip_trunks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id", null: false
    t.string "name", null: false
    t.string "host", null: false
    t.string "route_prefixes", default: [], null: false, array: true
    t.string "dial_string_prefix"
    t.boolean "trunk_prefix", default: false, null: false
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "nat_supported", default: true, null: false
    t.boolean "plus_prefix", default: false, null: false
    t.index ["carrier_id"], name: "index_outbound_sip_trunks_on_carrier_id"
    t.index ["sequence_number"], name: "index_outbound_sip_trunks_on_sequence_number", unique: true, order: :desc
  end

  create_table "phone_call_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "phone_call_id", null: false
    t.json "params", default: {}, null: false
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.uuid "phone_number_id"
    t.json "variables", default: {}, null: false
    t.string "direction", null: false
    t.bigserial "sequence_number", null: false
    t.uuid "inbound_sip_trunk_id"
    t.text "twiml"
    t.uuid "outbound_sip_trunk_id"
    t.uuid "carrier_id", null: false
    t.string "dial_string"
    t.decimal "price", precision: 10, scale: 4
    t.string "price_unit"
    t.index ["account_id"], name: "index_phone_calls_on_account_id"
    t.index ["carrier_id"], name: "index_phone_calls_on_carrier_id"
    t.index ["direction"], name: "index_phone_calls_on_direction"
    t.index ["external_id"], name: "index_phone_calls_on_external_id", unique: true
    t.index ["from"], name: "index_phone_calls_on_from"
    t.index ["inbound_sip_trunk_id"], name: "index_phone_calls_on_inbound_sip_trunk_id"
    t.index ["outbound_sip_trunk_id"], name: "index_phone_calls_on_outbound_sip_trunk_id"
    t.index ["phone_number_id"], name: "index_phone_calls_on_phone_number_id"
    t.index ["sequence_number"], name: "index_phone_calls_on_sequence_number", unique: true, order: :desc
    t.index ["status"], name: "index_phone_calls_on_status"
    t.index ["to"], name: "index_phone_calls_on_to"
  end

  create_table "phone_numbers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.string "number", null: false
    t.string "voice_url"
    t.string "voice_method"
    t.string "status_callback_url"
    t.string "status_callback_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigserial "sequence_number", null: false
    t.uuid "carrier_id", null: false
    t.string "sip_domain"
    t.index ["account_id"], name: "index_phone_numbers_on_account_id"
    t.index ["carrier_id"], name: "index_phone_numbers_on_carrier_id"
    t.index ["number", "carrier_id"], name: "index_phone_numbers_on_number_and_carrier_id", unique: true
    t.index ["number"], name: "index_phone_numbers_on_number"
    t.index ["sequence_number"], name: "index_phone_numbers_on_sequence_number", unique: true, order: :desc
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "carrier_id"
    t.string "carrier_role"
    t.string "name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.bigserial "sequence_number", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.uuid "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.uuid "current_account_membership_id"
    t.index ["carrier_id"], name: "index_users_on_carrier_id"
    t.index ["current_account_membership_id"], name: "index_users_on_current_account_membership_id"
    t.index ["email"], name: "index_users_on_email", unique: true
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_webhook_request_logs_on_event_id"
    t.index ["sequence_number"], name: "index_webhook_request_logs_on_sequence_number", unique: true, order: :desc
    t.index ["webhook_endpoint_id"], name: "index_webhook_request_logs_on_webhook_endpoint_id"
  end

  add_foreign_key "account_memberships", "accounts", on_delete: :cascade
  add_foreign_key "account_memberships", "users", on_delete: :cascade
  add_foreign_key "accounts", "carriers"
  add_foreign_key "accounts", "outbound_sip_trunks", on_delete: :nullify
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "call_data_records", "phone_calls"
  add_foreign_key "events", "carriers"
  add_foreign_key "exports", "users"
  add_foreign_key "inbound_sip_trunks", "carriers"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_applications", "carriers", column: "owner_id"
  add_foreign_key "outbound_sip_trunks", "carriers"
  add_foreign_key "phone_call_events", "phone_calls"
  add_foreign_key "phone_calls", "accounts"
  add_foreign_key "phone_calls", "carriers"
  add_foreign_key "phone_calls", "inbound_sip_trunks"
  add_foreign_key "phone_calls", "outbound_sip_trunks"
  add_foreign_key "phone_calls", "phone_numbers"
  add_foreign_key "phone_numbers", "accounts"
  add_foreign_key "phone_numbers", "carriers"
  add_foreign_key "users", "account_memberships", column: "current_account_membership_id", on_delete: :nullify
  add_foreign_key "users", "carriers"
  add_foreign_key "webhook_endpoints", "oauth_applications"
  add_foreign_key "webhook_request_logs", "events"
  add_foreign_key "webhook_request_logs", "webhook_endpoints"
end
