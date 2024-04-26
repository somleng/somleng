class CreateIncomingPhoneNumbers < ActiveRecord::Migration[7.1]
  class PhoneNumberConfiguration < ActiveRecord::Base
    belongs_to :phone_number
  end

  class PhoneNumber < ActiveRecord::Base
    self.inheritance_column = :_type_disabled

    has_one :configuration, class_name: "PhoneNumberConfiguration"
    has_one :active_plan, -> { active }, class_name: "PhoneNumberPlan"

    def self.assigned
      joins(:active_plan)
    end
  end

  def change
    reversible do |dir|
      dir.up do
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

        PhoneNumber.assigned.find_each do |phone_number|
          incoming_phone_number = IncomingPhoneNumber.new(
            phone_number:,
            number: phone_number.number,
            phone_number_plan: phone_number.active_plan,
            account: phone_number.active_plan.account,
            account_type: phone_number.active_plan.account_type,
            carrier: phone_number.carrier,
            created_at: phone_number.active_plan.created_at,
            updated_at: phone_number.active_plan.updated_at,
            status: :active,
            friendly_name: PhoneNumberFormatter.new.format(phone_number.number, format: :international)
          )

          if phone_number.configuration.present?
            incoming_phone_number.attributes = {
              voice_url: phone_number.configuration.voice_url,
              voice_method: phone_number.configuration.voice_method,
              sms_url: phone_number.configuration.sms_url,
              sms_method: phone_number.configuration.sms_method,
              status_callback_url: phone_number.configuration.status_callback_url,
              status_callback_method: phone_number.configuration.status_callback_method,
              sip_domain: phone_number.configuration.sip_domain
            }
          end

          incoming_phone_number.save!
        end

        drop_table(:phone_number_configurations)
      end

      dir.down do
        create_table :phone_number_configurations, id: :uuid do |t|
          t.references(:phone_number, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true })
          t.string(:voice_url)
          t.string(:voice_method)
          t.string(:status_callback_url)
          t.string(:status_callback_method)

          t.string(:sip_domain)

          t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

          t.timestamps

          t.string(:sms_url)
          t.string(:sms_method)
          t.references(:messaging_service, type: :uuid, null: true, foreign_key: { on_delete: :nullify })
        end

        IncomingPhoneNumber.active.find_each do |incoming_phone_number|
          PhoneNumberConfiguration.create!(
            phone_number: incoming_phone_number.phone_number,
            voice_url: incoming_phone_number.voice_url,
            voice_method: incoming_phone_number.voice_method,
            sms_url: incoming_phone_number.sms_url,
            sms_method: incoming_phone_number.sms_method,
            status_callback_url: incoming_phone_number.status_callback_url,
            status_callback_method: incoming_phone_number.status_callback_method,
            sip_domain: incoming_phone_number.sip_domain,
            created_at: incoming_phone_number.created_at,
            updated_at: incoming_phone_number.updated_at
          )
        end

        drop_table :incoming_phone_numbers
      end
    end
  end
end
