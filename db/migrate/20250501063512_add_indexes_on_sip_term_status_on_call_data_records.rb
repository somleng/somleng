class AddIndexesOnSIPTermStatusOnCallDataRecords < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index(:call_data_records, :sip_term_status, algorithm: :concurrently)
    add_index(:call_data_records, :sip_invite_failure_status, algorithm: :concurrently)
  end
end
