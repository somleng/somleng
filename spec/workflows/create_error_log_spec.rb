require "rails_helper"

RSpec.describe CreateErrorLog do
  it "creates an error log" do
    error_log = CreateErrorLog.call(
      type: :inbound_message,
      error_message: "An error message"
    )

    expect(error_log).to be_persisted
  end

  it "notifies subscribed carrier team members" do
    carrier = create(:carrier, name: "Rocket Communications")

    subscribed_user = create_subscribed_user(
      carrier:,
      subscribed_notification_topics: [ "error_logs.inbound_message" ]
    )
    _unsubscribed_user = create_subscribed_user(carrier:, subscribed_notification_topics: [])

    error_log = perform_enqueued_jobs do
      CreateErrorLog.call(
        type: :inbound_message,
        carrier:,
        error_message: "An error message"
      )
    end

    expect(error_log.notifications.pluck(:email)).to match_array([ subscribed_user.email ])
    expect(last_email_sent).to deliver_to([ subscribed_user.email ])
    expect(last_email_sent).to have_subject("Rocket Communications - New Issue: An error message")
  end

  it "notifies subscribed account team members" do
    carrier = create(:carrier, name: "Rocket Communications")
    _carrier_user = create_subscribed_user(carrier:, subscribed_notification_topics: [ "error_logs.inbound_message" ])
    account = create(:account, :customer_managed, carrier:)
    subscribed_user = create_subscribed_user(account:, subscribed_notification_topics: [ "error_logs.inbound_message" ])
    _unsubscribed_user = create_subscribed_user(account:, subscribed_notification_topics: [])

    error_log = perform_enqueued_jobs do
      CreateErrorLog.call(
        type: :inbound_message,
        carrier:,
        account:,
        error_message: "An error message"
      )
    end

    expect(error_log.notifications.pluck(:email)).to match_array([ subscribed_user.email ])
    expect(last_email_sent).to deliver_to(subscribed_user.email)
    expect(last_email_sent).to have_subject("Rocket Communications - New Issue: An error message")
  end

  def create_subscribed_user(**params)
    account = params.delete(:account)
    carrier_role = :admin if account.blank?
    user = create(:user, carrier_role:, **params)
    create(:account_membership, account:, user:) if account.present?
    user
  end
end
