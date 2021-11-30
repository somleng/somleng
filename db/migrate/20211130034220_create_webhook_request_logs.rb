class CreateWebhookRequestLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :webhook_request_logs, id: :uuid do |t|
      t.references :event, type: :uuid, null: false, foreign_key: true
      t.references :webhook_endpoint, type: :uuid, null: false, foreign_key: true
      t.string :url, null: false
      t.string :http_status_code, null: false
      t.boolean :failed, null: false
      t.jsonb :payload, default: {}, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
