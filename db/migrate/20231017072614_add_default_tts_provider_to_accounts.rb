class AddDefaultTTSProviderToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :default_tts_provider, :string
    reversible do |dir|
      dir.up do
        Account.update_all(default_tts_provider: :basic)
      end
    end

    change_column_null :accounts, :default_tts_provider, false
  end
end
