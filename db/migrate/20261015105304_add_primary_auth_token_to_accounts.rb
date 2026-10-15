class AddPrimaryAuthTokenToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :accounts,
      :primary_auth_token,
      type: :uuid,
      index: { unique: true },
      null: false,
      foreign_key: {
        to_table: :oauth_access_tokens,
        on_destroy: :nullify
      }
    )
  end
end
