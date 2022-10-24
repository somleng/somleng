class CreateSMSGateways < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_gateways, id: :uuid do |t|
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
