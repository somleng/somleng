class AddCallLegToCallDataRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :call_data_records, :call_leg, :string

    reversible do |dir|
      dir.up do
        CallDataRecord.update_all(call_leg: "A")
      end
    end

    change_column_null :call_data_records, :call_leg, false
  end
end
