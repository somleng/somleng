class CreateInboundSourceIPAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :inbound_source_ip_addresses, id: :uuid do |t|
      t.inet :ip, null: false, index: { unique: true }
      t.string :region, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
