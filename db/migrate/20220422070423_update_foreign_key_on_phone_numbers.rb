class UpdateForeignKeyOnPhoneNumbers < ActiveRecord::Migration[7.0]
  def up
    remove_foreign_key :phone_numbers, :accounts
    add_foreign_key :phone_numbers, :accounts, on_delete: :nullify
  end

  def down
    remove_foreign_key :phone_numbers, :accounts
    add_foreign_key :phone_numbers, :accounts
  end
end
