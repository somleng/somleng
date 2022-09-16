class AddSIPTrunkIDToPhoneCalls < ActiveRecord::Migration[7.0]
  def change
    add_reference(:phone_calls, :sip_trunk, type: :uuid, foreign_key: { on_delete: :nullify })
  end
end
