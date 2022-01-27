class AddPlusPrefixToOutboundSIPTrunks < ActiveRecord::Migration[6.1]
  def change
    add_column :outbound_sip_trunks, :plus_prefix, :boolean, null: false, default: false
  end
end
