class AddInboundSIPTrunkIDToPhoneCalls < ActiveRecord::Migration[6.1]
  def change
    add_reference(:phone_calls, :inbound_sip_trunk, type: :uuid, foreign_key: true)
  end
end
