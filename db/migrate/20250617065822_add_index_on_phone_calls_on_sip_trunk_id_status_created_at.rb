class AddIndexOnPhoneCallsOnSIPTrunkIDStatusCreatedAt < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index(
      :phone_calls,
      [ :sip_trunk_id, :status, :created_at ],
      algorithm: :concurrently
    )
  end
end
