class CreateErrorLogNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :error_log_notifications, id: :uuid do |t|
      t.references :error_log, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :email, null: false
      t.string :message_digest, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps

      t.index %i[message_digest user_id]
    end
  end
end
