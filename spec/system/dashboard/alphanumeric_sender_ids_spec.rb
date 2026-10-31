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
      account:,
      sender_id: "FooCompany"
    )
    other_alphanumeric_sender_id = create(
      :alphanumeric_sender_id,
      account: create(:account, carrier:)
    )
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_alphanumeric_sender_ids_path(
      filter: {
        account_id: alphanumeric_sender_id.account_id,
        sender_id: "Foo"
      }
    )

    expect(page).to have_text(alphanumeric_sender_id.id)
    expect(page).to have_no_text(other_alphanumeric_sender_id.id)
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

  it "Manage alphanumeric sender ids as an account owner" do
    carrier = create(:carrier)
    account = create(:account, :customer_managed, carrier:)
    alphanumeric_sender_id = create(:alphanumeric_sender_id, account:)
    other_alphanumeric_sender_id = create(:alphanumeric_sender_id, account: create(:account, carrier:))
    user = create(:user, :with_account_membership, account_role: :owner, account:)

    carrier_sign_in(user)
    visit dashboard_alphanumeric_sender_ids_path

    expect(page).to have_text(alphanumeric_sender_id.id)
    expect(page).to have_no_text(other_alphanumeric_sender_id.id)

    click_on("New")
    fill_in("Sender ID", with: "MySender1")
    click_on("Request")

    expect(page).to have_text("Alphanumeric Sender ID was successfully requested")
    expect(page).to have_text("MySender1")
    expect(page).to have_text("Pending approval")

    click_on("Delete")

    expect(page).to have_text("Alphanumeric Sender ID was successfully destroyed.")
  end
end
