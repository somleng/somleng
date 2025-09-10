class AddSIPProfileToSIPTrunks < ActiveRecord::Migration[8.0]
  def change
    add_column :sip_trunks, :sip_profile, :string
    add_index :sip_trunks, :sip_profile

    reversible do |dir|
      dir.up do
        SIPTrunk.where(outbound_symmetric_latching_supported: false).update_all(sip_profile: :nat_instance)
        SIPTrunk.where(outbound_symmetric_latching_supported: true).update_all(sip_profile: :nat_gateway)
      end
    end

    change_column_null :sip_trunks, :sip_profile, false
    remove_column :sip_trunks, :outbound_symmetric_latching_supported, :boolean, null: false, default: true
  end
end
