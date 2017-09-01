class AddRecordingToPhoneCall < ActiveRecord::Migration[5.1]
  def change
    add_reference(:phone_calls, :recording, :index => true, :foreign_key => true, :type => :uuid)
  end
end
