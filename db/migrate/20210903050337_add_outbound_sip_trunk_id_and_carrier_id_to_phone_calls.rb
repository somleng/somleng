class AddOutboundSIPTrunkIDAndCarrierIDToPhoneCalls < ActiveRecord::Migration[6.1]
  def change
    add_reference :phone_calls, :outbound_sip_trunk, type: :uuid, foreign_key: true
    add_reference :phone_calls, :carrier, type: :uuid, foreign_key: true
    add_column    :phone_calls, :dial_string, :string

    reversible do |dir|
      dir.up do
        execute <<-SQL
        UPDATE phone_calls pc
        SET carrier_id = a.carrier_id
        FROM accounts a where pc.account_id = a.id
        SQL
      end
    end

    change_column_null(:phone_calls, :carrier_id, false)
  end
end
