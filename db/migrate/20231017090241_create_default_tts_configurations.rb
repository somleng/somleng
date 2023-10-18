class CreateDefaultTTSConfigurations < ActiveRecord::Migration[7.1]
  def change
    create_table :default_tts_configurations, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :voice_identifier, null: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Account.find_each do |account|
          DefaultTTSConfiguration.create!(
            account:,
            voice_identifier: "Basic.kal"
          )
        end
      end
    end
  end
end
