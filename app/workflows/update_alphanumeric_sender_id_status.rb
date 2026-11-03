class UpdateAlphanumericSenderIDStatus < ApplicationWorkflow
  attr_reader :record, :status, :notify, :notification_topic

  def initialize(record, status:, **options)
    super()
    @record = record
    @status = status
    @notify = options.fetch(:notify, false)
    @notification_topic = options.fetch(:notification_topic) {
      User::NOTIFICATION_TOPICS.find { it.identifier == "admin_notifications.alphanumeric_sender_id_updates" }
    }
  end

  def call
    record.transition_to!(status)
    notify_subscribed_recipients if notify? && record.account.customer_managed?
    record
  end

  private

  def notify?
    !!notify
  end

  def notify_subscribed_recipients
    recipients = record.account.users.subscribed_to_notifications_for(notification_topic.identifier)

    return if recipients.none?

    AdminNotificationMailer.alphanumeric_sender_id_request_updated(
      recipients: AdminNotification.create_for!(users: recipients, topic: notification_topic.name),
      alphanumeric_sender_id: record,
    ).deliver_later
  end
end
