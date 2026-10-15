class AddPrimaryAuthTokenToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :accounts,
      :primary_auth_token,
      type: :uuid,
      foreign_key: {
        to_table: :oauth_access_tokens,
        on_destroy: :nullify
      }
    )

    reversible do |dir|
      dir.up do
        Account.find_each do |account|
          auth_token = account.auth_tokens.first || account.auth_tokens.create!(account:)

          account.update_columns(primary_auth_token_id: auth_token.id)
        end
      end
    end

    change_column_null(:accounts, :primary_auth_token_id, false)
  end
end
