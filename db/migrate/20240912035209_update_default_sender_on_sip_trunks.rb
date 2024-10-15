class UpdateDefaultSenderOnSIPTrunks < ActiveRecord::Migration[7.2]
  def change
    add_column(:sip_trunks, :default_sender, :string)
    add_index(:sip_trunks, :default_sender)
    remove_reference(:sip_trunks, :default_sender, type: :uuid, foreign_key: { to_table: :phone_numbers, on_delete: :nullify })
  end
end
