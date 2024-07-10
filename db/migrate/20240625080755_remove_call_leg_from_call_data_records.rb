class RemoveCallLegFromCallDataRecords < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        CallDataRecord.where(call_leg: "B").delete_all

        duplicate_cdrs = CallDataRecord.where(phone_call_id: CallDataRecord.select(:phone_call_id).group(:phone_call_id).having("count(phone_call_id) > 1"))
        duplicate_cdrs.where.not(id: duplicate_cdrs.select("DISTINCT ON(phone_call_id) id")).delete_all
      end
    end

    remove_column(:call_data_records, :call_leg, :string)
    remove_index(:call_data_records, :phone_call_id)
    add_index(:call_data_records, :phone_call_id, unique: true)
  end
end
