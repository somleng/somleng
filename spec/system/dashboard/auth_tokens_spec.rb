require "rails_helper"

RSpec.describe "Auth Tokens" do
  it "List auth tokens" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    other_auth_token = create(:auth_token)
    customer_managed_auth_token = create(
      :auth_token,
      account: create(:account, :customer_managed, carrier: create(:carrier))
    )
    auth_token = create(:auth_token, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_auth_tokens_path

    expect(page).to have_link(account.name, href: dashboard_account_path(account))
    expect(page).to have_text("Active")
    expect(page).to have_text(auth_token.id)
    expect(page).to have_no_text(other_auth_token.id)
    expect(page).to have_no_text(customer_managed_auth_token.id)
  end

  it "Filter auth tokens" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    other_auth_token = create(:auth_token, account: create(:account, carrier:))
    revoked_auth_token = create(:auth_token, :revoked, account:)
    secondary_auth_token = create(:auth_token, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_auth_tokens_path(
      filter: {
        account_id: account.id,
        active: true,
        primary: true
      }
    )

    expect(page).to have_text(account.primary_auth_token.id)
    expect(page).to have_no_text(secondary_auth_token.id)
    expect(page).to have_no_text(other_auth_token.id)
    expect(page).to have_no_text(revoked_auth_token.id)
  end

  it "Manages auth tokens as an account owner" do
    carrier = create(:carrier)
    account = create(:account, :customer_managed, carrier:)
    primary_auth_token = account.primary_auth_token
    secondary_auth_token = create(:auth_token, account:)
    other_auth_token = create(:auth_token, account: create(:account, :customer_managed, carrier:))
    user = create(:user, :with_account_membership, account_role: :owner, account:)

    carrier_sign_in(user)

    visit dashboard_auth_tokens_path

    expect(page).to have_text(primary_auth_token.id)
    expect(page).to have_text(secondary_auth_token.id)
    expect(page).to have_no_text(account.name)
    expect(page).to have_no_text(other_auth_token.id)

    click_on("New")

    expect(page).to have_text("Auth token was successfully created.")

    click_on(secondary_auth_token.id)
    click_on("Promote")

    expect(page).to have_text("Primary")

    visit(dashboard_auth_token_path(primary_auth_token))
    click_on("Revoke")

    expect(page).to have_text("Auth token was successfully revoked.")
  end

  it "Show an auth token" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    auth_token = create(:auth_token, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_auth_token_path(auth_token)

    expect(page).to have_text(auth_token.id)
    expect(page).to have_text(account.name)
    expect(page).to have_text("Active")
    expect(page).to have_text("Secondary")
  end

  it "Revoke an auth token" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    auth_token = create(:auth_token, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_auth_token_path(auth_token)

    click_on("Revoke")

    expect(page).to have_text("Auth token was successfully revoked.")
    expect(page).to have_text("Revoked")
    expect(page).to have_text(auth_token.reload.revoked_at.iso8601)
  end

  it "Create an auth token" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_auth_tokens_path(filter: { account_id: account.id })
    click_on("New")

    expect(page).to have_text("Auth token was successfully created")
  end

  it "Promote an auth token" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :carrier, carrier:)
    auth_token = create(:auth_token, account:)

    carrier_sign_in(user)
    visit dashboard_auth_token_path(auth_token)

    click_on("Promote")

    expect(page).to have_text("Auth token was successfully updated.")
  end
end
