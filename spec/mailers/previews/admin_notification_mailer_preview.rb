class AdminNotificationMailerPreview < ActionMailer::Preview
  def alphanumeric_sender_ids_pending_approval
    carrier = Carrier.first

    AdminNotificationMailer.alphanumeric_sender_ids_pending_approval(
      recipients: carrier.carrier_users,
      carrier:
    )
  end
end
