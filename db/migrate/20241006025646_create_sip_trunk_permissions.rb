class CreateSIPTrunkPermissions < ActiveRecord::Migration[7.2]
  def change
    create_table :sip_trunk_permissions, id: :uuid do |t|
      t.inet :source_ip, null: false, index: { unique: true }

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
