class CreateAudioStreams < ActiveRecord::Migration[7.1]
  def change
    create_table :audio_streams, id: :uuid do |t|
      t.references(:phone_call, type: :uuid, null: false, foreign_key: true)
      t.references(:account, type: :uuid, null: false, foreign_key: true)
      t.string(:url, null: false)

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
