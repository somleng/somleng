class CreateIncomingPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    create_table :incoming_phone_numbers, id: :uuid do |t|
      t.references(:phone_number_plan, type: :uuid, null: false, foreign_key: true, index: { unique: true })
      t.references(:account, type: :uuid, null: false, foreign_key: true)
      t.references(:carrier, type: :uuid, null: false, foreign_key: true)
      t.references(:phone_number, type: :uuid, null: true, foreign_key: { on_delete: :nullify })
      t.references(:messaging_service, type: :uuid, null: true, foreign_key: { on_delete: :nullify })
      t.string(:friendly_name, null: false)
      t.string(:account_type, null: false)
      t.index(:account_type)
      t.string(:number, null: false)
      t.index(:number)
      t.string(:status, null: false)
      t.index([ :status, :phone_number_id ], unique: true, where: "status = 'active'")
      t.string(:voice_url)
      t.string(:voice_method, null: false)
      t.string(:sms_url)
      t.string(:sms_method, null: false)
      t.string(:status_callback_url)
      t.string(:status_callback_method, null: false)
      t.string(:sip_domain)
      t.datetime(:released_at)
      t.index(:released_at)

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    drop_table(:phone_number_configurations)
  end
end
