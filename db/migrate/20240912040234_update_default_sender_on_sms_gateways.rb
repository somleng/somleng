class UpdateDefaultSenderOnSMSGateways < ActiveRecord::Migration[7.2]
  def change
    add_column(:sms_gateways, :default_sender, :string)
    add_index(:sms_gateways, :default_sender)

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE sms_gateways
          SET default_sender = phone_numbers.number
          FROM phone_numbers where phone_numbers.id = sms_gateways.default_sender_id
        SQL
      end
    end

    remove_reference(:sms_gateways, :default_sender, type: :uuid, foreign_key: { to_table: :phone_numbers, on_delete: :nullify })
  end
end
