class AddCarrierIdToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_reference(:accounts, :carrier, type: :uuid, foreign_key: true, null: false)
    add_reference(:accounts, :outbound_sip_trunk, type: :uuid, foreign_key: true)
    add_column(:accounts, :allowed_calling_codes, :string, null: false, array: true, default: [])
    rename_column(:accounts, :state, :status)
  end
end
