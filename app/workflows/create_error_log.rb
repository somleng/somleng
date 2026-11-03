class CreateErrorLog < ApplicationWorkflow
  attr_reader :params

  def initialize(params)
    super()
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

    return if recipients.none?

    ErrorLogNotification.create_for!(users: recipients, error_log:)
    ErrorLogMailer.notify(error_log:).deliver_later
  end

  def find_potential_recipients(error_log)
    return User.none if error_log.carrier.blank?

    users = if error_log.account&.customer_managed?
      error_log.account.users
    else
      error_log.carrier.carrier_users
    end

    users.subscribed_to_notifications_for("error_logs.#{error_log.type}")
  end
end
