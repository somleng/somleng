class CreateCarrierAPIAllowedIPAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :carrier_api_allowed_ip_addresses, id: :uuid do |t|
      t.references :oauth_application, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.inet :ip_address, null: false


      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index :carrier_api_allowed_ip_addresses, [ :oauth_application_id, :ip_address ], unique: true
  end
end
