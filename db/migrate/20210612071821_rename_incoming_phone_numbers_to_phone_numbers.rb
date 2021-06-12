class RenameIncomingPhoneNumbersToPhoneNumbers < ActiveRecord::Migration[6.1]
  def change
    rename_table :incoming_phone_numbers, :phone_numbers
    rename_column :phone_calls, :incoming_phone_number_id, :phone_number_id
  end
end
