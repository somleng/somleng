class CreateTTSConfigurations < ActiveRecord::Migration[7.1]
  def change
    create_table :tts_configurations, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: { on_delete: :cascade },
                             index: { unique: true }
      t.string :voice_identifier, null: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Account.find_each do |account|
          TTSConfiguration.create!(
            account:,
            voice_identifier: "Basic.Kal"
          )
        end
      end
    end
  end
end
