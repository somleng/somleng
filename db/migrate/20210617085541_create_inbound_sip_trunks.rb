class CreateInboundSIPTrunks < ActiveRecord::Migration[6.1]
  def change
    create_table :inbound_sip_trunks, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.inet :source_ip, null: false
      t.index :source_ip, unique: true
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
