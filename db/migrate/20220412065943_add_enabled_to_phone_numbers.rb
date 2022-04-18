class AddEnabledToPhoneNumbers < ActiveRecord::Migration[7.0]
  def change
    add_column :phone_numbers, :enabled, :boolean, default: true, null: false
    add_index :phone_numbers, :enabled
  end
end
