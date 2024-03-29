class CreateMediaStreamEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :media_stream_events, id: :uuid do |t|
      t.references :phone_call, type: :uuid, null: false, foreign_key: true
      t.references :media_stream, type: :uuid, null: false, foreign_key: true
      t.jsonb(:details, null: false, default: {})
      t.string(:type, null: false)

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
