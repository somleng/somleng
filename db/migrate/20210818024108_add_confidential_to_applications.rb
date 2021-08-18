# frozen_string_literal: true

class AddConfidentialToApplications < ActiveRecord::Migration[6.1]
  def change
    add_column(
      :oauth_applications,
      :confidential,
      :boolean,
      null: false,
      default: true
    )
  end

  remove_foreign_key :oauth_applications, :accounts, column: :owner_id
  remove_foreign_key :oauth_access_tokens, :accounts, column: :resource_owner_id
end
