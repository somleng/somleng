class AddNotificationTypesToUser < ActiveRecord::Migration[7.1]
  def change
    add_column(:users, :subscribed_notification_topics, :string, array: true, null: false, default: [])
  end
end
