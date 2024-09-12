class UpdateDefaultSenderOnSIPTrunks < ActiveRecord::Migration[7.2]
  def change
    add_column(:sip_trunks, :default_sender, :string)
    add_index(:sip_trunks, :default_sender)

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE sip_trunks
          SET default_sender = phone_numbers.number
          FROM phone_numbers where phone_numbers.id = sip_trunks.default_sender_id
        SQL
      end
    end

    remove_reference(:sip_trunks, :default_sender, type: :uuid, foreign_key: { to_table: :phone_numbers, on_delete: :nullify })
  end
end
