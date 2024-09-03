class AddRegionToSIPTrunk < ActiveRecord::Migration[7.2]
  def change
    add_column(:sip_trunks, :region, :string)

    reversible do |dir|
      dir.up do
        SIPTrunk.update_all(region: "hydrogen")
      end
    end

    change_column_null(:sip_trunks, :region, false)
    add_index(:sip_trunks, :region)
  end
end
