class ErrorLogMailer < ApplicationMailer
  helper ApplicationHelper
  layout "carrier_mailer"

  def notify(error_log:)
    @error_log = error_log
    @carrier = error_log.carrier
    @host = @carrier.account_host

    bootstrap_mail(
      to: error_log.notifications.pluck(:email),
      subject: "#{@carrier.name} - New Issue: #{error_log.error_message.truncate(50)}"
    )
  end
end
