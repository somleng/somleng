class AddDefaultTTSVoiceToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :default_tts_voice, :string

    reversible do |dir|
      dir.up do
        Account.update_all(default_tts_voice: "Basic.Kal")
        Account.where(carrier_id: "3b9ed636-7619-4b83-84eb-c5e7a4c2b872").update_all(
          default_tts_voice: "Polly.Mia"
        )
      end
    end

    change_column_null(:accounts, :default_tts_voice, false)
  end
end
