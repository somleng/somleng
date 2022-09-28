class RenameSIPTrunkColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column(:sip_trunks, :outbound_trunk_prefix, :outbound_national_dialing)
    add_column(:sip_trunks, :inbound_country_code, :string)
    remove_column(:sip_trunks, :inbound_trunk_prefix_replacement, :string)
  end
end
