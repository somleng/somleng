class AddNotificationTypesToUser < ActiveRecord::Migration[7.1]
  def change
    add_column(:users, :subscribed_notification_topics, :string, array: true, null: false, default: [])

    reversible do |dir|
      dir.up do
        User.update_all(subscribed_notification_topics: [ :error_logs ])
      end
    end
  end
end
