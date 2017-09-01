class AddRecordingToPhoneCallEvent < ActiveRecord::Migration[5.1]
  def change
    add_reference(:phone_call_events, :recording, :type => :uuid, :index => true, :foreign_key => true)
  end
end
