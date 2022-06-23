class CreateErrorLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :error_logs, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: true, foreign_key: true
      t.references :account, type: :uuid, null: true, foreign_key: true
      t.string :error_message, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps
    end
  end
end
