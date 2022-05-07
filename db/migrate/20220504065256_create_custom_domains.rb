class CreateCustomDomains < ActiveRecord::Migration[7.0]
  def change
    create_table :custom_domains, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: true
      t.string :host, null: false
      t.string :verification_token, null: false
      t.string :type, null: false
      t.datetime :verification_started_at
      t.datetime :verified_at

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps
    end

    add_index :custom_domains, %i[carrier_id type], unique: true
    add_index :custom_domains, %i[carrier_id host], unique: true
    add_index :custom_domains, :verification_token, unique: true
    add_index :custom_domains, :host, unique: true, where: "(verified_at IS NOT NULL)"
    add_index :custom_domains, :type
    add_index :custom_domains, :verification_started_at
    add_index :custom_domains, :verified_at
  end
end
