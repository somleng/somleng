class AddIndexOnPhoneCallsOnStatusAndRegion < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index(:phone_calls, %i[status region], algorithm: :concurrently)
  end
end
