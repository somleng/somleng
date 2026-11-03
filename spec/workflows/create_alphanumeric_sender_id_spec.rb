require "rails_helper"

RSpec.describe CreateAlphanumericSenderID do
  it "creates an alphanumeric sender id for a carrier managed account" do
    account = create(:account, :carrier_managed)

    result = CreateAlphanumericSenderID.call(
      {
        account:,
        sender_id: "MyCompany"
      }
    )

    expect(result).to have_attributes(
      persisted?: true,
      approved?: true,
      sender_id: "MyCompany",
      account:,
      carrier: account.carrier,
    )
  end

  it "creates an alphanumeric sender id for a customer managed account" do
    account = create(:account, :customer_managed)

    result = CreateAlphanumericSenderID.call(
      {
        account:,
        sender_id: "MyCompany"
      }
    )

    expect(result).to have_attributes(
      persisted?: true,
      pending_approval?: true,
      sender_id: "MyCompany",
      account:,
      carrier: account.carrier,
    )
  end

  it "notifies subscribed users" do
    carrier = create(:carrier)
    account = create(:account, :customer_managed, carrier:)
    subscribed_user = create(
      :user,
      :carrier,
      carrier:,
      subscribed_notification_topics: [ "admin_notifications.alphanumeric_sender_id_updates" ]
    )
    unsubscribed_user = create(
      :user, :carrier, carrier:
    )
    recently_notified_user = create(
      :user,
      :carrier,
      carrier:,
      subscribed_notification_topics: [ "admin_notifications.alphanumeric_sender_id_updates" ]
    )
    create(:admin_notification, topic: :alphanumeric_sender_id_updates, user: recently_notified_user)

    perform_enqueued_jobs do
      result = CreateAlphanumericSenderID.call(
        {
          account:,
          sender_id: "MyCompany"
        },
        notify: true
      )

      expect(result).to be_persisted
    end

    expect(subscribed_user.admin_notifications).to contain_exactly(
      have_attributes(
        topic: "alphanumeric_sender_id_updates"
      )
    )
    expect(unsubscribed_user.admin_notifications).to be_empty
    expect(account.owner.admin_notifications).to be_empty
    expect(recently_notified_user.admin_notifications.count).to eq(1)
    expect(last_email_sent).to deliver_to(subscribed_user.email)
    expect(last_email_sent).to have_subject("New Alphanumeric Sender IDs pending approval")
  end
end
