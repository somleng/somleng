class AddSIPTrunkIDToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_reference(:accounts, :sip_trunk, type: :uuid, foreign_key: true)
  end
end
