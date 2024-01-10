class CreateVerificationServices < ActiveRecord::Migration[7.1]
  def change
    create_table :verification_services, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: true
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :code_length, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
