class CreateLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :logs, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: true
      t.references :account, type: :uuid, foreign_key: true
      t.references :phone_number, type: :uuid, foreign_key: true
      t.string :type, null: false
      t.string :status, null: false
      t.string :error_message
      t.text :body

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
