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

  def alphanumeric_sender_id_request_updated(recipients:, alphanumeric_sender_id:)
    @alphanumeric_sender_id = alphanumeric_sender_id
    @carrier = alphanumeric_sender_id.carrier
    @host = @alphanumeric_sender_id.carrier.account_host

    bootstrap_mail(
      to: recipients,
      subject: "#{@carrier.name} - Your Alphanumeric Sender ID request has been #{@alphanumeric_sender_id.status.text.downcase}."
    )
  end
end
