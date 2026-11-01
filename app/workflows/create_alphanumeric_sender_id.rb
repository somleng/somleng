class CreateAlphanumericSenderID < ApplicationWorkflow
  attr_reader :params, :notify, :notify_options

  def initialize(params, **options)
    super()
    @params = params
    @notify = options.fetch(:notify, false)
    @notify_options = options.fetch(:notify_options) {
      {
        topic_namespace: :admin_notifications,
        topic: :alphanumeric_sender_ids_approvals
      }
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
    potential_recipients = carrier.carrier_users.subscribed_to_notifications_for(fully_qualified_notification_topic)
    recent_notifications = AdminNotification.recent_notifications_for(notify_options.fetch(:topic))
    recipients_to_notify = potential_recipients.where.not(id: recent_notifications.select(:user_id))

    AdminNotification.insert_all!(
      recipients_to_notify.pluck(:email, :id).map do |email, id|
        {
          email:,
          user_id: id,
          topic: notify_options.fetch(:topic)
        }
      end
    )
  end

  def fully_qualified_notification_topic
    [ notify_options.fetch(:topic_namespace), notify_options.fetch(:topic) ].join(".")
  end
end
