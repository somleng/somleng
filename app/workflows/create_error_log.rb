class CreateErrorLog < ApplicationWorkflow
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def call
    ErrorLog.transaction do
      error_log = create_error_log
      notify_subscribed_recipients(error_log)
      error_log
    end
  end

  private

  def create_error_log
    ErrorLog.create!(params)
  end

  def notify_subscribed_recipients(error_log)
    recipients = find_potential_recipients(error_log)
      .subscribed_to_notifications_for(:error_logs)
      .reject { |recipient| recipient_recently_notified?(recipient, error_log.error_message) }

    notifications = recipients.map do |recipient|
      ErrorLogNotification.create!(
        error_log:,
        user: recipient,
        email: recipient.email,
        message_digest: error_log.error_message
      )
    end

    return if notifications.blank?

    ErrorLogMailer.notify(error_log:).deliver_later
  end

  def find_potential_recipients(error_log)
    return User.none if error_log.carrier.blank?
    return error_log.account.users if error_log.account&.customer_managed?

    error_log.carrier.carrier_users
  end

  def recipient_recently_notified?(user, error_message)
    ErrorLogNotification.exists?(
      user:,
      message_digest: error_message,
      created_at: 1.month.ago..
    )
  end
end
