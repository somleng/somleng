require "rails_helper"

RSpec.describe "Alphanumeric Sender IDs" do
  it "List alphanumeric sender ids" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    alphanumeric_sender_id = create(
      :alphanumeric_sender_id,
      :approved,
      account:,
      sender_id: "MyCompany"
    )
    other_alphanumeric_sender_id = create(:alphanumeric_sender_id)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_alphanumeric_sender_ids_path

    expect(page).to have_link(account.name, href: dashboard_account_path(account))
    expect(page).to have_text("Approved")
    expect(page).to have_text("MyCompany")
    expect(page).to have_text(alphanumeric_sender_id.id)
    expect(page).to have_no_text(other_alphanumeric_sender_id.id)
  end

  it "Filter alphanumeric sender ids" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    alphanumeric_sender_id = create(
      :alphanumeric_sender_id,
      :approved,
      account:,
      sender_id: "FooCompany",
    )
    other_alphanumeric_sender_id = create(
      :alphanumeric_sender_id,
      account: create(:account, carrier:)
    )
    messaging_service = create(:messaging_service, account:)
    create(:messaging_service_alphanumeric_sender_id, messaging_service:, sender_id: alphanumeric_sender_id)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_alphanumeric_sender_ids_path(
      filter: {
        account_id: alphanumeric_sender_id.account_id,
        sender_id: "Foo",
        status: "approved",
        messaging_service_id: messaging_service.id
      }
    )

    expect(page).to have_text(alphanumeric_sender_id.id)
    expect(page).to have_no_text(other_alphanumeric_sender_id.id)
  end

  it "Show an alphanumeric sender id" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    alphanumeric_sender_id = create(:alphanumeric_sender_id, account:)
    messaging_service = create(:messaging_service, account:, name: "My Messaging Service")
    create(:messaging_service_alphanumeric_sender_id, messaging_service:, sender_id: alphanumeric_sender_id)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_alphanumeric_sender_id_path(alphanumeric_sender_id)

    expect(page).to have_link("My Messaging Service", href: dashboard_messaging_service_path(messaging_service))
  end

  it "Create an alphanumeric sender id" do
    carrier = create(:carrier)
    account = create(:account, :carrier_managed, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_alphanumeric_sender_ids_path(filter: { account_id: account.id })
    click_on("New")
    fill_in("Sender ID", with: "MyCompany")
    click_on("Request")

    expect(page).to have_text("Alphanumeric Sender ID was successfully requested")
    expect(page).to have_text("MyCompany")
    expect(page).to have_text("Approved")
    expect(page).to have_link(account.name, href: dashboard_account_path(account))
  end

  it "Handles validation errors" do
    carrier = create(:carrier)
    account = create(:account, :carrier_managed, carrier:)
    create(:alphanumeric_sender_id, :approved, account:, sender_id: "MyCompany")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_alphanumeric_sender_id_path
    select(account.name, from: "Account")
    fill_in("Sender ID", with: "MyCompany")
    click_on("Request")

    expect(page).to have_text("Sender ID has already been taken")
  end

  it "Delete an alphanumeric sender id" do
    carrier = create(:carrier)
    account = create(:account, :carrier_managed, carrier:)
    alphanumeric_sender_id = create(:alphanumeric_sender_id, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_alphanumeric_sender_id_path(alphanumeric_sender_id)
    click_on("Delete")

    expect(page).to have_text("Alphanumeric Sender ID was successfully destroyed")
  end

  it "Approve an alphanumeric sender id" do
    carrier = create(:carrier, name: "Rocket Communications")
    account = create(
      :account,
      :customer_managed,
      carrier:,
      account_memberships: [
        build(
          :account_membership,
          :owner,
          user: create(
            :user,
            carrier:,
            subscribed_notification_topics: [
              "admin_notifications.alphanumeric_sender_id_updates"
            ]
          )
        )
      ]
    )
    alphanumeric_sender_id = create(:alphanumeric_sender_id, :pending_approval, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_alphanumeric_sender_id_path(alphanumeric_sender_id)
    perform_enqueued_jobs do
      click_on("Approve")
    end

    expect(page).to have_text("Alphanumeric Sender ID was successfully updated")
    within("#status") do
      expect(page).to have_text("Approved")
    end
    within("#approved-at") do
      expect(page).to have_css("time")
    end
    expect(last_email_sent).to deliver_to(account.owner.email)
    expect(last_email_sent).to have_subject("Rocket Communications - Your Alphanumeric Sender ID request has been approved.")
  end

  it "Reject an alphanumeric sender id" do
    carrier = create(:carrier)
    account = create(:account, :customer_managed, carrier:)
    alphanumeric_sender_id = create(:alphanumeric_sender_id, :pending_approval, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_alphanumeric_sender_id_path(alphanumeric_sender_id)
    click_on("Reject")

    expect(page).to have_text("Alphanumeric Sender ID was successfully updated")
    within("#status") do
      expect(page).to have_text("Rejected")
    end
    within("#rejected-at") do
      expect(page).to have_css("time")
    end
  end

  it "Revoke an alphanumeric sender id" do
    carrier = create(:carrier)
    account = create(:account, :customer_managed, carrier:)
    alphanumeric_sender_id = create(:alphanumeric_sender_id, :approved, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_alphanumeric_sender_id_path(alphanumeric_sender_id)
    click_on("Revoke")

    expect(page).to have_text("Alphanumeric Sender ID was successfully updated")
    within("#status") do
      expect(page).to have_text("Revoked")
    end
    within("#revoked-at") do
      expect(page).to have_css("time")
    end
  end

  it "Manage alphanumeric sender ids as an account owner" do
    carrier = create(:carrier)
    account = create(:account, :customer_managed, carrier:)
    alphanumeric_sender_id = create(:alphanumeric_sender_id, account:)
    other_alphanumeric_sender_id = create(:alphanumeric_sender_id, account: create(:account, carrier:))
    carrier_admin = create(:user, :carrier, :admin, carrier:, subscribed_notification_topics: [ "admin_notifications.alphanumeric_sender_id_updates" ])
    user = create(:user, :with_account_membership, account_role: :owner, account:)

    carrier_sign_in(user)
    visit dashboard_alphanumeric_sender_ids_path

    expect(page).to have_text(alphanumeric_sender_id.id)
    expect(page).to have_no_text(other_alphanumeric_sender_id.id)

    click_on("New")

    expect(page).to have_no_field("Account")

    fill_in("Sender ID", with: "MySender1")
    perform_enqueued_jobs do
      click_on("Request")
    end

    expect(page).to have_text("Alphanumeric Sender ID was successfully requested")
    expect(page).to have_text("MySender1")
    expect(page).to have_text("Pending approval")
    expect(last_email_sent).to deliver_to(carrier_admin.email)
    expect(last_email_sent).to have_subject("New Alphanumeric Sender IDs pending approval")

    click_on("Delete")

    expect(page).to have_text("Alphanumeric Sender ID was successfully destroyed.")
  end
end
