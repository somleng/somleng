class AddMissingIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index(:phone_calls, %i[account_id created_at], algorithm: :concurrently)
    add_index(:phone_calls, %i[account_id id], algorithm: :concurrently)
    add_index(:phone_calls, %i[status initiated_at], algorithm: :concurrently)
    add_index(:phone_calls, %i[status initiating_at], algorithm: :concurrently)
    add_index(:phone_calls, %i[status created_at], algorithm: :concurrently)
  end
end
