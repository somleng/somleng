class AddRegionToSIPTrunk < ActiveRecord::Migration[7.2]
  def change
    add_column(:sip_trunks, :region, :string, null: false)
    add_index(:sip_trunks, :region)
  end
end
