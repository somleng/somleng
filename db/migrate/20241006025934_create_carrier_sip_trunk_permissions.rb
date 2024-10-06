class CreateCarrierSIPTrunkPermissions < ActiveRecord::Migration[7.2]
  def change
    create_table :carrier_sip_trunk_permissions, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :sip_trunk_permission, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index :carrier_sip_trunk_permissions, %i[carrier_id sip_trunk_permission_id], unique: true
  end
end
