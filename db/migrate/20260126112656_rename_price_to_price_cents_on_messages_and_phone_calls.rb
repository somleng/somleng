class RenamePriceToPriceCentsOnMessagesAndPhoneCalls < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    rename_column :messages, :price, :price_cents
    rename_column :phone_calls, :price, :price_cents

    reversible do |dir|
      dir.up do
        PhoneCall.where.not(price_cents: nil).update_all("price_cents = price_cents * 100")
      end
    end

    add_index(:messages, :price_cents, algorithm: :concurrently)
    add_index(:messages, :price_unit, algorithm: :concurrently)
  end
end
