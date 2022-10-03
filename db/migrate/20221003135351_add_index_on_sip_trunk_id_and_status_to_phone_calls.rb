class AddIndexOnSIPTrunkIDAndStatusToPhoneCalls < ActiveRecord::Migration[7.0]
  def change
    add_index(:phone_calls, [:sip_trunk_id, :status])
  end
end
