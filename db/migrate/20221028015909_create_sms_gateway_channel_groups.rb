class CreateSMSGatewayChannelGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_gateway_channel_groups, id: :uuid do |t|
      t.references :sms_gateway, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.string :route_prefixes, default: [], null: false, array: true
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
