class RenamePriceToPriceCentsOnMessagesAndPhoneCalls < ActiveRecord::Migration[8.1]
  def change
    rename_column :messages, :price, :price_cents
    rename_column :phone_calls, :price, :price_cents
  end
end
