class AddRecordingStatusCallbackUrlAndRecordingStatusCallbackMethodToPhoneCalls < ActiveRecord::Migration[7.0]
  def change
    change_table :phone_calls do |t|
      t.column :recording_status_callback_url, :string
      t.column :recording_status_callback_method, :string
    end
  end
end
