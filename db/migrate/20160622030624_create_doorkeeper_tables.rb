class CreateDoorkeeperTables < ActiveRecord::Migration
  def change
    create_table(:oauth_applications, :id => :uuid, :default => "gen_random_uuid()") do |t|
      t.string  :name,         null: false
      t.string  :uid,          null: false
      t.uuid    :owner_id,     null: false
      t.string  :secret,       null: false
      t.text    :redirect_uri, null: false
      t.string  :scopes,       null: false, default: ''
      t.timestamps             null: false
    end

    add_foreign_key(:oauth_applications, :accounts, :column => :owner_id)
    add_index :oauth_applications, :uid, unique: true

    create_table(:oauth_access_grants, :id => :uuid, :default => "gen_random_uuid()") do |t|
      t.uuid     :resource_owner_id, null: false
      t.uuid     :application_id,    null: false
      t.string   :token,             null: false
      t.integer  :expires_in,        null: false
      t.text     :redirect_uri,      null: false
      t.datetime :created_at,        null: false
      t.datetime :revoked_at
      t.string   :scopes
      t.timestamps                   null: false
    end

    add_foreign_key(:oauth_access_grants, :accounts, :column => :resource_owner_id)
    add_foreign_key(:oauth_access_grants, :oauth_applications, :column => :application_id)
    add_index :oauth_access_grants, :token, unique: true

    create_table(:oauth_access_tokens, :id => :uuid, :default => "gen_random_uuid()") do |t|
      t.uuid     :resource_owner_id, :null => false
      t.uuid     :application_id

      # If you use a custom token generator you may need to change this column
      # from string to text, so that it accepts tokens larger than 255
      # characters. More info on custom token generators in:
      # https://github.com/doorkeeper-gem/doorkeeper/tree/v3.0.0.rc1#custom-access-token-generator
      #
      # t.text     :token,             null: false
      t.string   :token,             null: false

      t.string   :refresh_token
      t.integer  :expires_in
      t.datetime :revoked_at
      t.datetime :created_at,        null: false
      t.string   :scopes
    end


    add_foreign_key(:oauth_access_tokens, :accounts, :column => :resource_owner_id)
    add_foreign_key(:oauth_access_tokens, :oauth_applications, :column => :application_id)

    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :resource_owner_id
    add_index :oauth_access_tokens, :refresh_token, unique: true
  end
end
