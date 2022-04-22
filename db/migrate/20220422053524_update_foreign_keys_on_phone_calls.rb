class UpdateForeignKeysOnPhoneCalls < ActiveRecord::Migration[7.0]
  def up
    remove_foreign_key :phone_calls, :inbound_sip_trunks
    remove_foreign_key :phone_calls, :outbound_sip_trunks
    remove_foreign_key :phone_calls, :phone_numbers

    add_foreign_key :phone_calls, :inbound_sip_trunks, on_delete: :nullify
    add_foreign_key :phone_calls, :outbound_sip_trunks, on_delete: :nullify
    add_foreign_key :phone_calls, :phone_numbers, on_delete: :nullify
  end

  def down
    remove_foreign_key :phone_calls, :inbound_sip_trunks
    remove_foreign_key :phone_calls, :outbound_sip_trunks
    remove_foreign_key :phone_calls, :phone_numbers

    add_foreign_key :phone_calls, :inbound_sip_trunks
    add_foreign_key :phone_calls, :outbound_sip_trunks
    add_foreign_key :phone_calls, :phone_numbers
  end
end
