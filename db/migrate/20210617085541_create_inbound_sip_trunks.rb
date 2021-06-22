class CreateInboundSIPTrunks < ActiveRecord::Migration[6.1]
  def change
    create_table :inbound_sip_trunks, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :trunk_prefix_replacement
      t.inet :source_ip, null: false
      t.index :source_ip, unique: true
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        if Rails.env.production?
          carrier_id = "b405d1a4-ebc4-46f8-9d7e-4a3eefa2fe8e"
          [["Metfone", "175.100.32.29"], ["Cellcard", "103.193.204.26"], ["Smart", "27.109.112.140"]].each do |(name, source_ip)|
            InboundSIPTrunk.create!(
              name: name,
              source_ip: source_ip,
              carrier_id: carrier_id,
              trunk_prefix_replacement: "855"
            )
          end
        end
      end
    end

    remove_column(:accounts, :settings, :jsonb)
  end
end
