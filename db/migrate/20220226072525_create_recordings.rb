class CreateRecordings < ActiveRecord::Migration[7.0]
  def change
    create_table :recordings, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :phone_call, type: :uuid, null: false, foreign_key: true
      t.string :status, null: false
      t.string :external_id
      t.string :raw_recording_url
      t.integer :duration
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
