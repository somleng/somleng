class CreateCustomDomainNames < ActiveRecord::Migration[7.0]
  def change
    create_table :custom_domain_names, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: true, index: { unique: true }
      t.string :host, null: false
      t.boolean :verified, default: false, null: false
      t.string :verification_token, null: false
      t.string :type, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps
    end
  end
end
