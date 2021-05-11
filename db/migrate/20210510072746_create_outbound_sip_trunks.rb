class CreateOutboundSipTrunks < ActiveRecord::Migration[6.1]
  def change
    create_table :outbound_sip_trunks, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :host, null: false
      t.string :route_prefixes, default: [], null: false, array: true
      t.string :dial_string_prefix
      t.boolean :trunk_prefix, null: false, default: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
