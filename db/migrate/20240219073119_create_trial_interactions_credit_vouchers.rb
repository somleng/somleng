class CreateTrialInteractionsCreditVouchers < ActiveRecord::Migration[7.1]
  def change
    create_table :trial_interactions_credit_vouchers, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.integer :number_of_interactions, null: false
      t.datetime :valid_at, null: false, index: true

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
