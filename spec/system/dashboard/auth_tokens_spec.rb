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
    auth_token = create(:auth_token, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_auth_tokens_path(
      filter: {
        account_id: account.id,
        active: true
      }
    )

    expect(page).to have_text(auth_token.id)
    expect(page).to have_no_text(other_auth_token.id)
    expect(page).to have_no_text(revoked_auth_token.id)
  end

  it "Manages auth tokens as an account owner" do
    carrier = create(:carrier)
    account = create(:account, :customer_managed, carrier:)
    auth_token = create(:auth_token, account:)
    other_auth_token = create(:auth_token, account: create(:account, :customer_managed, carrier:))
    user = create(:user, :with_account_membership, account_role: :owner, account:)

    carrier_sign_in(user)
    visit dashboard_auth_tokens_path

    expect(page).to have_text(auth_token.id)
    expect(page).to have_no_text(account.name)
    expect(page).to have_no_text(other_auth_token.id)

    click_on("New")

    expect(page).to have_text("Auth token was successfully created.")

    click_on(auth_token.id)
    click_on("Revoke")

    expect(page).to have_text("Auth token was successfully revoked.")
  end

  it "show an auth token" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    auth_token = create(:auth_token, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_auth_token_path(auth_token)

    expect(page).to have_text(auth_token.id)
    expect(page).to have_text(account.name)
  end

  it "revoke an auth token" do
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

  it "create an auth token" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_auth_tokens_path(filter: { account_id: account.id })
    click_on("New")

    expect(page).to have_text("Auth token was successfully created.")
  end
end
