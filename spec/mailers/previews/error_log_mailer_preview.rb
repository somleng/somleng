class ErrorLogMailerPreview < ActionMailer::Preview
  def notify_carrier_user
    error_log = ErrorLog
               .joins(:notifications)
               .where.not(carrier_id: nil)
               .where(account_id: nil).last

    ErrorLogMailer.notify(error_log:)
  end

  def notify_account_user
    error_log = ErrorLog
               .joins(:notifications)
               .joins(:account)
               .merge(Account.customer_managed).last

    ErrorLogMailer.notify(error_log:)
  end
end
