class AdminNotificationMailer < ApplicationMailer
  helper ApplicationHelper
  layout "carrier_mailer"

  def alphanumeric_sender_ids_pending_approval(recipients:, carrier:)
    @carrier = carrier
    @host = @carrier.account_host

    bootstrap_mail(
      to: recipients,
      subject: "New Alphanumeric Sender IDs pending approval"
    )
  end
end
