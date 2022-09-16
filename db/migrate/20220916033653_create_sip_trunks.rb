class CreateSIPTrunks < ActiveRecord::Migration[7.0]
  def change
    create_table :sip_trunks, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.inet   :inbound_source_ip, null: true
      t.string :inbound_trunk_prefix_replacement, null: true

      t.string :outbound_host, null: true
      t.string :outbound_route_prefixes, default: [], null: false, array: true
      t.string :outbound_dial_string_prefix, null: true
      t.boolean :outbound_trunk_prefix, default: false, null: false
      t.boolean :outbound_plus_prefix, default: false, null: false
      t.boolean :outbound_symmetric_latching_supported, default: true, null: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps

      t.index :inbound_source_ip, unique: true
    end
  end
end
