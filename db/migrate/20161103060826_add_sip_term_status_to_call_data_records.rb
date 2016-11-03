class AddSipTermStatusToCallDataRecords < ActiveRecord::Migration[5.0]
  def change
    add_column(:call_data_records, :sip_term_status, :string)
  end
end
