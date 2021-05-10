class AddCarrierIdToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_reference :accounts, :carrier, type: :uuid, foreign_key: true
    add_reference :accounts, :outbound_sip_trunk, type: :uuid, foreign_key: true

    reversible do |dir|
      Account.update_all(carrier_id: SecureRandom.uuid)
    end

    change_column_null :accounts, :carrier_id, false
  end
end
