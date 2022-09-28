class RemoveOldSIPTrunks < ActiveRecord::Migration[7.0]
  def up
    remove_column :phone_calls, :outbound_sip_trunk_id, :uuid
    remove_column :phone_calls, :inbound_sip_trunk_id, :uuid
    remove_column :accounts, :outbound_sip_trunk_id, :uuid

    drop_table :outbound_sip_trunks
    drop_table :inbound_sip_trunks
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
