class AddSettingsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column(:accounts, :settings, :jsonb, default: {}, null: false)
  end
end
