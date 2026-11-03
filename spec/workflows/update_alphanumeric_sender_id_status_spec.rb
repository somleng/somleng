require "rails_helper"

RSpec.describe UpdateAlphanumericSenderIDStatus do
  it "updates the status of an alphanumeric sender id" do
    alphanumeric_sender_id = create(:alphanumeric_sender_id, :pending_approval)

    result = UpdateAlphanumericSenderIDStatus.call(alphanumeric_sender_id, status: :approved)

    expect(result).to have_attributes(approved?: true)
  end

  it "notifies subscribed users" do
    carrier = create(:carrier, name: "Rocket Communications")
    account = create(:account, :customer_managed, carrier:)
    alphanumeric_sender_id = create(:alphanumeric_sender_id, :pending_approval, account:)
    subscribed_user = create(
      :user,
      subscribed_notification_topics: [ "admin_notifications.alphanumeric_sender_id_updates" ]
    )
    create(:account_membership, account:, user: subscribed_user)
    unsubscribed_user = create(:user)
    create(:account_membership, account:, user: unsubscribed_user)

    perform_enqueued_jobs do
      UpdateAlphanumericSenderIDStatus.call(
        alphanumeric_sender_id, status: "approved", notify: true
      )
    end

    expect(subscribed_user.admin_notifications).to contain_exactly(
      have_attributes(
        topic: "alphanumeric_sender_id_updates"
      )
    )
    expect(unsubscribed_user.admin_notifications).to be_empty
    expect(last_email_sent).to deliver_to(subscribed_user.email)
    expect(last_email_sent).to have_subject("Rocket Communications - Your Alphanumeric Sender ID request has been approved.")
  end
end
