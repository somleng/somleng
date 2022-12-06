class CreateSMSGatewayChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_gateway_channels, id: :uuid do |t|
      t.references :sms_gateway, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references(
        :channel_group,
        type: :uuid,
        null: false,
        foreign_key: {
          to_table: :sms_gateway_channel_groups,
          on_delete: :cascade
        }
      )

      t.integer :slot_index, limit: 2, null: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.index %i[slot_index sms_gateway_id], unique: true
      t.timestamps
    end
  end
end
