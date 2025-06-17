class AddIndexOnPhoneCallsOnAccountIDInternalAndSequenceNumber < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index(
      :phone_calls,
      [ :account_id, :internal, :sequence_number ],
      order: { sequence_number: :desc },
      algorithm: :concurrently
    )
  end
end
