class AdminNotification < ApplicationRecord
  extend Enumerize

  enumerize :topic, in: User::NOTIFICATION_TOPICS.select { it.category.admin_notifications? }.map(&:name)

  belongs_to :user

  def self.recent_notifications_for(topic, since: 24.hours.ago)
    where(topic:).where(created_at: since..)
  end

  def self.create_for!(users:, topic:, returning: :email)
    insert_all!(
      users.pluck(:email, :id).map do |email, id|
        {
          email:,
          user_id: id,
          topic:
        }
      end,
      returning: [ returning ]
    ).pluck(returning.to_s)
  end
end
