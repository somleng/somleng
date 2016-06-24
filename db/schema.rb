# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160622045632) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "accounts", id: :uuid, default: "gen_random_uuid()", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_access_grants", id: :uuid, default: "gen_random_uuid()", force: :cascade do |t|
    t.uuid     "resource_owner_id", null: false
    t.uuid     "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
    t.datetime "updated_at",        null: false
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", id: :uuid, default: "gen_random_uuid()", force: :cascade do |t|
    t.uuid     "resource_owner_id", null: false
    t.uuid     "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", id: :uuid, default: "gen_random_uuid()", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.uuid     "owner_id",                  null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "phone_calls", id: :uuid, default: "gen_random_uuid()", force: :cascade do |t|
    t.uuid     "account_id",             null: false
    t.string   "to",                     null: false
    t.string   "from",                   null: false
    t.string   "voice_url",              null: false
    t.string   "voice_method",           null: false
    t.string   "status",                 null: false
    t.string   "status_callback_url"
    t.string   "status_callback_method"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "phone_calls", ["account_id"], name: "index_phone_calls_on_account_id", using: :btree

  add_foreign_key "oauth_access_grants", "accounts", column: "resource_owner_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "accounts", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_applications", "accounts", column: "owner_id"
  add_foreign_key "phone_calls", "accounts"
end
