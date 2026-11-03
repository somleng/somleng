class CreateAlphanumericSenderID < ApplicationWorkflow
  attr_reader :params, :notify, :notification_topic

  def initialize(params, **options)
    super()
    @params = params
    @notify = options.fetch(:notify, false)
    @notification_topic = options.fetch(:notification_topic) {
      User::NOTIFICATION_TOPICS.find { it.identifier == "admin_notifications.alphanumeric_sender_id_updates" }
    }
  end

  def call
    alphanumeric_sender_id = create_alphanumeric_sender_id
    notify_subscribed_recipients(alphanumeric_sender_id.carrier) if notify? && alphanumeric_sender_id.account.customer_managed?
    alphanumeric_sender_id
  end

  private

  def create_alphanumeric_sender_id
    AlphanumericSenderID.create!(
      carrier: params.fetch(:account).carrier,
      status: params.fetch(:account).carrier_managed? ? :approved : :pending_approval,
      **params
    )
  end

  def notify?
    !!notify
  end

  def notify_subscribed_recipients(carrier)
    potential_recipients = carrier.carrier_users.subscribed_to_notifications_for(notification_topic.identifier)
    recent_notifications = AdminNotification.recent_notifications_for(notification_topic.name)
    recipients = potential_recipients.where.not(id: recent_notifications.select(:user_id))

    return if recipients.none?

    AdminNotificationMailer.alphanumeric_sender_ids_pending_approval(
      recipients: AdminNotification.create_for!(users: recipients, topic: notification_topic.name),
      carrier:
    ).deliver_later
  end
end
