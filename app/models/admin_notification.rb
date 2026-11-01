class AdminNotification < ApplicationRecord
  belongs_to :user

  def self.recent_notifications_for(topic, recency: 24.hours.ago)
    where(topic:).where(created_at: recency..)
  end
end
