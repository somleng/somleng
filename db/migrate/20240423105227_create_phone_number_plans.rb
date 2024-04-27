class CreatePhoneNumberPlans < ActiveRecord::Migration[7.1]
  class PhoneNumber < ActiveRecord::Base
    self.inheritance_column = :_type_disabled

    belongs_to :account, optional: true

    monetize :price_cents, with_model_currency: :currency, numericality: {
      greater_than_or_equal_to: 0
    }
  end

  class PhoneNumberPlan < ActiveRecord::Base
    belongs_to :phone_number, optional: true
    belongs_to :account
    belongs_to :carrier

    attribute :number, PhoneNumberType.new

    monetize :amount_cents, with_model_currency: :currency, numericality: {
      greater_than_or_equal_to: 0
    }
  end

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

    reversible do |dir|
      dir.up do
        PhoneNumber.where.not(account_id: nil).find_each do |phone_number|
          PhoneNumberPlan.create!(
            phone_number:,
            number: phone_number.number,
            account_id: phone_number.account_id,
            carrier_id: phone_number.carrier_id,
            created_at: phone_number.updated_at,
            updated_at: phone_number.updated_at,
            amount: phone_number.price,
            status: :active
          )
        end
      end
    end
  end
end
