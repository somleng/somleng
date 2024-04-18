class ErrorLogMailer < ApplicationMailer
  helper ApplicationHelper

  def notify(error_log:)
    @error_log = error_log
    @other_notifications = other_notifications
    @carrier = error_log.carrier
    @host = @carrier.account_host

    subject = "#{@carrier.name} - New Issue: #{error_log.error_message.truncate(50)}"

    bootstrap_mail(to: error_log.notifications.pluck(:email), subject:) do |format|
      format.html { render(layout: "carrier_mailer") }
    end
  end

  private

  def other_notifications
    ErrorLogNotification.where(message_digest: @error_log.error_message)
  end
end
