class AddTimestampFieldsToCallDataRecords < ActiveRecord::Migration[5.0]
  def parse_epoch(variables, key)
    epoch = variables["key"].to_i
    Time.at(epoch) if epoch > 0
  end

  def up
    add_column(:call_data_records, :start_time, :datetime)
    add_column(:call_data_records, :end_time, :datetime)
    add_column(:call_data_records, :answer_time, :datetime)

    CallDataRecord.find_each do |cdr|
      variables = JSON.parse(cdr.file.read)["variables"]

      cdr.update_columns(
        :start_time => parse_epoch(variables, "start_epoch"),
        :end_time => parse_epoch(variables, "end_epoch"),
        :answer_time => parse_epoch(variables, "answer_epoch")
      )
    end

    change_column(:call_data_records, :start_time, :datetime, :null => false)
    change_column(:call_data_records, :end_time, :datetime, :null => false)
  end

  def down
    remove_column(:call_data_records, :start_time)
    remove_column(:call_data_records, :end_time)
    remove_column(:call_data_records, :answer_time)
  end
end
