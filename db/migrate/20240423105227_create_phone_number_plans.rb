class CreatePhoneNumberPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :phone_number_plans, id: :uuid do |t|
      t.references(:phone_number, type: :uuid, foreign_key: { on_delete: :nullify })
      t.references(:carrier, type: :uuid, foreign_key: true)
      t.references(:account, type: :uuid, foreign_key: true)

      t.string(:number, null: false)
      t.integer(:amount_cents, null: false)
      t.string(:currency, null: false)
      t.string(:status, null: false)
      t.datetime(:canceled_at)

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps

      t.index(:number)
      t.index(:status)
      t.index(:canceled_at)
      t.index([ :amount_cents, :currency ])
      t.index([ :phone_number_id, :status ], unique: true, where: "status = 'active'")
    end
  end
end
