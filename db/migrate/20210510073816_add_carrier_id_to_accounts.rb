class AddCarrierIdToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_reference(:accounts, :carrier, type: :uuid, foreign_key: true)
    add_reference(:accounts, :outbound_sip_trunk, type: :uuid, foreign_key: true)
    add_column(:accounts, :allowed_calling_codes, :string, null: false, array: true, default: [])

    reversible do |dir|
      dir.up do
        # This will a foreign key constraint
        # Move data migration here and remove after deploy
        Account.update_all(carrier_id: SecureRandom.uuid)
      end
    end

    change_column_null(:accounts, :carrier_id, false)
  end
end
