class AddCurrentAccountMembershipIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference(
      :users,
      :current_account_membership,
      type: :uuid,
      null: true,
      foreign_key: { to_table: :account_memberships, on_delete: :nullify }
    )
  end
end
