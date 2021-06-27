class AddCallLegToCallDataRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :call_data_records, :call_leg, :string, default: "A", null: false
    add_index :call_data_records, :call_leg, where: "call_leg = 'A'"
  end
end
