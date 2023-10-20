class CreateTTSEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :tts_events, id: :uuid do |t|
      t.references :carrier, type: :uuid, foreign_key: true, null: false
      t.references :account, type: :uuid, foreign_key: { on_delete: :nullify }
      t.references :phone_call, type: :uuid, foreign_key: { on_delete: :nullify }
      t.integer :num_chars, null: false
      t.string :tts_voice, null: false
      t.index :created_at

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
