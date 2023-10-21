class AddDefaultTTSVoiceToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :default_tts_voice, :string, null: false
  end
end
