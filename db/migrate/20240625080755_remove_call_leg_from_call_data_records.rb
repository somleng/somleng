class RemoveCallLegFromCallDataRecords < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        CallDataRecord.where(call_leg: "B").delete_all

        unique = CallDataRecord.select("DISTINCT ON(phone_call_id) id")
        CallDataRecord.where.not(id: unique).delete_all
      end
    end

    remove_column(:call_data_records, :call_leg, :string)
    remove_index(:call_data_records, :phone_call_id)
    add_index(:call_data_records, :phone_call_id, unique: true)
  end
end
