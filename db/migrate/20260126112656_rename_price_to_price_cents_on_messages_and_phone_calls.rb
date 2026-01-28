class RenamePriceToPriceCentsOnMessagesAndPhoneCalls < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    rename_column :messages, :price, :price_cents
    rename_column :phone_calls, :price, :price_cents

    add_index(:messages, :price_cents, algorithm: :concurrently)
    add_index(:messages, :price_unit, algorithm: :concurrently)
  end
end
