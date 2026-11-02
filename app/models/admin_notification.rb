class AdminNotification < ApplicationRecord
  extend Enumerize

  enumerize :topic, in: User::NOTIFICATION_TOPICS.select { it.category.admin_notifications? }.map(&:name)

  belongs_to :user

  def self.recent_notifications_for(topic, since: 24.hours.ago)
    where(topic:).where(created_at: since..)
  end
end
