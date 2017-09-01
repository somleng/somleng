class AddRecordingToAwsSnsMessage < ActiveRecord::Migration[5.1]
  def change
    add_reference(:aws_sns_messages, :recording, :index => true, :foreign_key => true, :type => :uuid)
  end
end
