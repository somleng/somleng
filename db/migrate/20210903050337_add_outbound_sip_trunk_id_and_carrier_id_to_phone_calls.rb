class AddOutboundSIPTrunkIDAndCarrierIDToPhoneCalls < ActiveRecord::Migration[6.1]
  def change
    add_reference :phone_calls, :outbound_sip_trunk, type: :uuid, foreign_key: true
    add_reference :phone_calls, :carrier, type: :uuid, foreign_key: true, null: false
    add_column    :phone_calls, :dial_string, :string
  end
end
