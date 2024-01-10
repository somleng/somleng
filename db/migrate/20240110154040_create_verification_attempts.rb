class CreateVerificationAttempts < ActiveRecord::Migration[7.1]
  def change
    create_table :verification_attempts, id: :uuid do |t|
      t.references :verification, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :code, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
