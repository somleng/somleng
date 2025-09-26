class AddIndexOnMessagesOnStatusAndSendingAt < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index(:messages, [ :status, :sending_at ], where: "status = 'sending'", algorithm: :concurrently)
  end
end
