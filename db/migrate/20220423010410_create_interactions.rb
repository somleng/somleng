class CreateInteractions < ActiveRecord::Migration[7.0]
  def change
    create_table :interactions, id: :uuid do |t|
      t.references :interactable,
                   polymorphic: true,
                   type: :uuid,
                   null: false,
                   index: { unique: true }

      t.references :carrier, type: :uuid, null: false, foreign_key: true
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.string :beneficiary_fingerprint, null: false
      t.string :beneficiary_country_code, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps
    end

    add_index :interactions, :created_at
    add_index :interactions, :beneficiary_fingerprint
    add_index :interactions, :beneficiary_country_code
  end
end
