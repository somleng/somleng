class AddIncomingMessageIDToMessages < ActiveRecord::Migration[7.1]
  def change
    add_reference(:messages, :incoming_phone_number, type: :uuid, foreign_key: true)
  end
end
