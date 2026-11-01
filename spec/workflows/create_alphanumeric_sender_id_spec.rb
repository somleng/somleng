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

  it "notifies subscribed recipients" do
    carrier = create(:carrier)
    account = create(:account, :customer_managed, carrier:)
    subscribed_recipient = create(
      :user,
      :carrier,
      carrier:,
      subscribed_notification_topics: [ "admin_notifications.alphanumeric_sender_ids_approvals" ]
    )
    unsubscribed_recipient = create(
      :user, :carrier, carrier:
    )
    recently_notified_recipient = create(
      :user,
      :carrier,
      carrier:,
      subscribed_notification_topics: [ "admin_notifications.alphanumeric_sender_ids_approvals" ]
    )
    create(:admin_notification, topic: :alphanumeric_sender_ids_approvals, user: recently_notified_recipient)

    result = CreateAlphanumericSenderID.call(
      {
        account:,
        sender_id: "MyCompany"
      },
      notify: true
    )

    expect(result).to be_persisted
    expect(subscribed_recipient.admin_notifications).to contain_exactly(
      have_attributes(
        topic: "alphanumeric_sender_ids_approvals"
      )
    )
    expect(unsubscribed_recipient.admin_notifications).to be_empty
    expect(recently_notified_recipient.admin_notifications.count).to eq(1)
  end
end
