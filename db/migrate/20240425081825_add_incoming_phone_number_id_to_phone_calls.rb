class AddIncomingPhoneNumberIDToPhoneCalls < ActiveRecord::Migration[7.1]
  def change
    add_reference(:phone_calls, :incoming_phone_number, type: :uuid, foreign_key: true)

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE phone_calls
          SET incoming_phone_number_id = incoming_phone_numbers.id
          FROM incoming_phone_numbers
          WHERE incoming_phone_numbers.phone_number_id = phone_calls.phone_number_id
          AND incoming_phone_numbers.account_id = phone_calls.account_id
          AND incoming_phone_numbers.status = 'active'
        SQL
      end
    end
  end
end
