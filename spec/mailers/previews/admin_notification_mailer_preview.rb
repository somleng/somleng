class AdminNotificationMailerPreview < ActionMailer::Preview
  def alphanumeric_sender_ids_pending_approval
    carrier = Carrier.first

    AdminNotificationMailer.alphanumeric_sender_ids_pending_approval(
      recipients: carrier.carrier_users.pluck(:email),
      carrier:
    )
  end

  def alphanumeric_sender_id_request_updated
    alphanumeric_sender_id = AlphanumericSenderID.first

    AdminNotificationMailer.alphanumeric_sender_id_request_updated(
      recipients: alphanumeric_sender_id.carrier.account_users.pluck(:email),
      alphanumeric_sender_id:
    )
  end
end
