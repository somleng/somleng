class CreateCallDataRecords < ActiveRecord::Migration[5.0]
  def change
    create_table(:call_data_records, :id => :uuid, :default => "gen_random_uuid()") do |t|
      t.references :phone_call, :null => false, :type => :uuid, :index => true, :foreign_key => true
      t.string     :file_id,           :null => false
      t.string     :file_filename,     :null => false
      t.integer    :file_size,         :null => false
      t.string     :file_content_type, :null => false
      t.integer    :bill_sec,          :null => false
      t.integer    :duration_sec,      :null => false
      t.string     :direction,         :null => false
      t.string     :hangup_cause,      :null => false
      t.timestamps
    end
  end
end
