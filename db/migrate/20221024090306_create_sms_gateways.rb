class CreateSMSGateways < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_gateways, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :device_token, null: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.index :device_token, unique: true
      t.timestamps
    end
  end
end
