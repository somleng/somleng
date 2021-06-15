class RenameIncomingPhoneNumbersToPhoneNumbers < ActiveRecord::Migration[6.1]
  def change
    rename_table :incoming_phone_numbers, :phone_numbers
    execute("ALTER SEQUENCE incoming_phone_numbers_sequence_number_seq RENAME TO phone_numbers_sequence_number_seq;")
    rename_column :phone_calls, :incoming_phone_number_id, :phone_number_id
  end
end
