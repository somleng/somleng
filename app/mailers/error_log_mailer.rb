class ErrorLogMailer < ApplicationMailer
  helper ApplicationHelper

  def notify(error_log:)
    @error_log = error_log
    @other_notifications = other_notifications
    @carrier = error_log.carrier

    if intended_for_customer?
      @organization_name = error_log.carrier.name
      @host = @carrier.account_host
      layout = "carrier_mailer"
    else
      @organization_name = "Somleng"
      @host = @carrier.subdomain_host
      layout = "mailer"
    end

    subject = "#{@organization_name} - New Issue: #{error_log.error_message.truncate(50)}"

    bootstrap_mail(to: error_log.notifications.pluck(:email), subject:) do |format|
      format.html { render(layout:) }
    end
  end

  private

  def other_notifications
    ErrorLogNotification.where(message_digest: @error_log.error_message)
  end

  def intended_for_customer?
    @error_log.account&.customer_managed?
  end
end
