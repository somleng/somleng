class CreateSIPTrunkInboundSourceIPAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :sip_trunk_inbound_source_ip_addresses, id: :uuid do |t|
      t.references :sip_trunk, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :inbound_source_ip_address, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :carrier, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.inet :ip, null: false, index: true
      t.string :region, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:sip_trunk_inbound_source_ip_addresses, [ :sip_trunk_id, :inbound_source_ip_address_id ], unique: true)
  end
end
