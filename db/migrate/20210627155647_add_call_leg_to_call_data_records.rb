class AddCallLegToCallDataRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :call_data_records, :call_leg, :string, null: false
  end
end
