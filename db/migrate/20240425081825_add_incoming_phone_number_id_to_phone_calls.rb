class AddIncomingPhoneNumberIDToPhoneCalls < ActiveRecord::Migration[7.1]
  def change
    add_reference(:phone_calls, :incoming_phone_number, type: :uuid, foreign_key: true)
  end
end
