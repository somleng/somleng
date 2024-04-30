class NotificationPreferencesForm
  NotificationTopic = Struct.new(:name, :category, keyword_init: true) do
    def self.parse(value)
      category, name = value.split(".", 2)
      new(category:, name:)
    end

    def identifier
      "#{category}.#{name}"
    end
  end

  include ActiveModel::Model
  include ActiveModel::Attributes
  extend Enumerize

  enumerize :subscribed_notification_topics,
            in: User.subscribed_notification_topics.values,
            multiple: true

  attribute :user
  attribute :subscribed_notification_topics, FilledArrayType.new, default: []

  delegate :persisted?, :new_record?, to: :user
  delegate :notification_topics, to: :class

  def self.model_name
    ActiveModel::Name.new(self, nil, "NotificationPreferences")
  end

  def self.notification_topics
    User.subscribed_notification_topics.values.map { |topic| NotificationTopic.parse(topic) }
  end

  def self.initialize_with(user)
    new(
      user:,
      subscribed_notification_topics: user.subscribed_notification_topics
    )
  end

  def save
    return false if invalid?
    user.update!(subscribed_notification_topics:)

    true
  end
end
