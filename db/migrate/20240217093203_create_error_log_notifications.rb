class CreateErrorLogNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :error_log_notifications, id: :uuid do |t|
      t.references :error_log, type: :uuid, null: false, foreign_key: true
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
      t.index :created_at
    end
  end
end
