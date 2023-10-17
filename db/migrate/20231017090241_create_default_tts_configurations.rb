class CreateDefaultTTSConfigurations < ActiveRecord::Migration[7.1]
  def change
    create_table :default_tts_configurations, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :provider, null: false
      t.string :language, null: false
      t.string :voice, null: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Account.find_each do |account|
          DefaultTTSConfiguration.create!(
            account:,
            provider: "basic",
            voice: "man",
            language: "en-us"
          )
        end
      end
    end
  end
end
