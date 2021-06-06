class UpdateForeignKeyOnAccountsToOutboundSIPTrunks < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :accounts, :outbound_sip_trunks
    add_foreign_key :accounts, :outbound_sip_trunks, on_delete: :nullify
  end
end
