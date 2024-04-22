class CreatePhoneNumberPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :phone_number_plans, id: :uuid do |t|
      t.references(:phone_number, type: :uuid, foreign_key: { on_delete: :nullify })
      t.references(:carrier, type: :uuid, foreign_key: true)
      t.references(:account, type: :uuid, foreign_key: true)
      t.string(:number, null: false)
      t.integer(:price_cents, null: false)
      t.string(:currency, null: false)
      t.datetime(:started_at, null: false)
      t.datetime(:canceled_at)

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
