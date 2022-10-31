class CreateSMSGatewayChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_gateway_channels, id: :uuid do |t|
      t.references :sms_gateway, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :sms_gateway_channel_group, type: :uuid, null: true, foreign_key: { on_delete: :nullify }
      t.references :phone_number, type: :uuid, null: true, foreign_key: { on_delete: :nullify }
      t.string :name, null: false
      t.integer :slot_index, limit: 2, null: false
      t.string :route_prefixes, default: [], null: false, array: true

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.index %i[slot_index sms_gateway_id], unique: true
      t.timestamps
    end
  end
end
