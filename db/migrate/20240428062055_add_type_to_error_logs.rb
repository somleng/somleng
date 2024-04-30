class AddTypeToErrorLogs < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        ErrorLog.delete_all
        User.update_all(subscribed_notification_topics: [])
      end
    end

    add_column(:error_logs, :type, :string, null: false)
  end
end
