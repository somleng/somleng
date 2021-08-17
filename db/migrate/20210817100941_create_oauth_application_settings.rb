class CreateOAuthApplicationSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :oauth_application_settings, id: :uuid do |t|
      t.references :oauth_application, null: false, type: :uuid, foreign_key: true
      t.inet :whitelisted_ips, default: [], null: false, array: true
      t.text :public_key

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
