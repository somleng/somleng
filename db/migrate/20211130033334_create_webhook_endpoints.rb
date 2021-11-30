class CreateWebhookEndpoints < ActiveRecord::Migration[6.1]
  def change
    create_table :webhook_endpoints, id: :uuid do |t|
      t.references :oauth_application, type: :uuid, null: false, foreign_key: true
      t.string :url, null: false
      t.string :signing_secret, null: false
      t.boolean :enabled, default: true, null: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
