class ErrorLogMailerPreview < ActionMailer::Preview
  def notify_carrier_user
    error_log_notification = ErrorLogNotification
                            .joins(:error_log)
                            .where.not(error_logs: { carrier_id: nil })
                            .where(error_logs: { account_id: nil }).last

    ErrorLogMailer.notify(error_log: error_log_notification.error_log)
  end

  def notify_account_user
    error_log_notification = ErrorLogNotification
                            .joins(error_log: :account)
                            .merge(Account.customer_managed).last

    ErrorLogMailer.notify(error_log: error_log_notification.error_log)
  end
end
