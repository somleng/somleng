class AddNatSupportedToOutboundSIPTrunks < ActiveRecord::Migration[6.1]
  def change
    add_column :outbound_sip_trunks, :nat_supported, :boolean, default: true, null: false
  end
end
