require "rails_helper"

RSpec.describe CreateErrorLog do
  it "creates an error log" do
    error_log = CreateErrorLog.call(
      error_message: "An error message"
    )

    expect(error_log).to be_persisted
  end

  it "notifies subscribed carrier team members" do
    carrier = create(:carrier)
    subscribed_user = create_subscribed_user(carrier:)
    _unsubscribed_user = create_subscribed_user(carrier:, subscribed_notification_topics: [])
    _recent_identical_error_log_notification = create(
      :error_log_notification,
      error_log_message: "An error message",
      carrier:
    )
    recent_different_error_log_notification = create(
      :error_log_notification,
      error_log_message: "Another error message",
      carrier:
    )
    old_identical_error_log_notification = create(
      :error_log_notification,
      error_log_message: "An error message",
      carrier:,
      created_at: 1.month.ago
    )

    error_log = perform_enqueued_jobs do
      CreateErrorLog.call(
        carrier:,
        error_message: "An error message"
      )
    end

    expect(error_log.notifications.pluck(:email)).to match_array(
      [
        subscribed_user.email,
        recent_different_error_log_notification.email,
        old_identical_error_log_notification.email
      ]
    )
    expect(last_email_sent).to deliver_to(
      [
        subscribed_user.email,
        recent_different_error_log_notification.email,
        old_identical_error_log_notification.email
      ]
    )
    expect(last_email_sent).to have_subject("Somleng - New Issue: An error message")
  end

  it "notifies subscribed account team members" do
    carrier = create(:carrier, name: "Rocket Communications")
    _carrier_user = create_subscribed_user(carrier:)
    account = create(:account, carrier:)
    subscribed_user = create_subscribed_user(account:)
    _unsubscribed_user = create_subscribed_user(account:, subscribed_notification_topics: [])

    error_log = perform_enqueued_jobs do
      CreateErrorLog.call(
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
    subscribed_notification_topics = params.fetch(:subscribed_notification_topics) { [ :error_logs ] }

    user = create(
      :user,
      carrier_role:,
      subscribed_notification_topics:,
      **params
    )

    user.update!(subscribed_notification_topics: []) if subscribed_notification_topics.blank?
    account_membership = create(:account_membership, account:, user:) if account.present?
    user
  end
end
