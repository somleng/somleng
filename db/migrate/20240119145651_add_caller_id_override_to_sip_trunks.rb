class AddCallerIDOverrideToSIPTrunks < ActiveRecord::Migration[7.1]
  def change
    add_reference(:sip_trunks, :caller_id_override, type: :uuid, foreign_key: { to_table: :phone_numbers, on_delete: :nullify })
  end
end
