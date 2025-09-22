class AddInitiationQueuedAtToPhoneCalls < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :phone_calls, :initiation_queued_at, :datetime
    add_index :phone_calls, [ :status, :created_at, :initiation_queued_at ], where: "status = 'queued'", algorithm: :concurrently
  end
end
