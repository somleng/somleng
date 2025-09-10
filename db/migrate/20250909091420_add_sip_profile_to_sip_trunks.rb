class AddSIPProfileToSIPTrunks < ActiveRecord::Migration[8.0]
  def change
    add_column :sip_trunks, :sip_profile, :string, null: false
    add_index :sip_trunks, :sip_profile
    remove_column :sip_trunks, :outbound_symmetric_latching_supported, :boolean, null: false, default: true
  end
end
