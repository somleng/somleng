class AddForeignKeyStrategyOnOAuthApplicationsAndAccessTokensToCarriers < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :oauth_access_grants, :oauth_applications, column: :application_id
    add_foreign_key :oauth_access_grants, :oauth_applications, column: :application_id, on_delete: :cascade

    remove_foreign_key :oauth_access_tokens, :oauth_applications, column: :application_id
    add_foreign_key :oauth_access_tokens, :oauth_applications, column: :application_id, on_delete: :cascade

    remove_foreign_key :oauth_applications, :carriers, column: "owner_id"
    add_foreign_key :oauth_applications, :carriers, column: :owner_id, on_delete: :cascade
  end
end
