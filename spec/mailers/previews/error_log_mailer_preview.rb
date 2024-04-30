class ErrorLogMailerPreview < ActionMailer::Preview
  def notify
    ErrorLogMailer.notify(error_log: ErrorLog.joins(:notifications).last)
  end
end
