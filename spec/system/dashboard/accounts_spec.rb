require "rails_helper"

RSpec.describe "Accounts" do
  it "List and filter accounts", :js do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(
      :account,
      name: "Rocket Rides",
      carrier:,
      created_at: Time.utc(2021, 12, 1),
      metadata: {
        "customer" => {
          "id" => "RR1234"
        }
      }
    )

    create(:account, name: "Garry Gas", carrier:, created_at: Time.utc(2021, 12, 10))
    create(:account, name: "Alice Apples", carrier:, created_at: Time.utc(2021, 10, 1))
    create(
      :account, :disabled, name: "Disabled Account", carrier:, created_at: Time.utc(2021, 12, 10)
    )

    carrier_sign_in(user)
    visit dashboard_accounts_path(
      filter: {
        from_date: "01/12/2021",
        to_date: "15/12/2021"
      }
    )
    click_button("Filter")
    check("Status")
    select("Enabled", from: "filter[status]")
    check("Metadata")
    fill_in("Key", with: "customer.id")
    fill_in("Value", with: "RR1234")
    click_button("Done")

    expect(page).to have_content("Filter 3")
    expect(page).to have_content("Rocket Rides")
    expect(page).not_to have_content("Garry Gas")
    expect(page).not_to have_content("Alice Apples")
    expect(page).not_to have_content("Disabled Account")
    expect(page).not_to have_content("Carrier Account")
  end

  it "Create an account" do
    user = create(:user, :carrier)

    carrier_sign_in(user)
    visit dashboard_accounts_path
    click_link("New")

    fill_in "Name", with: "Rocket Rides"
    fill_in "Calls per second", with: 2
    select("Polly", from: "Default TTS provider")
    click_button "Create Account"

    expect(page).to have_content("Account was successfully created")
    expect(page).to have_content("Calls per second2")
    expect(page).to have_content("Rocket Rides")
    expect(page).to have_content("Enabled")
    expect(page).to have_link("Edit")
    expect(page).to have_content("Auth Token")
    expect(page).to have_content("Carrier managed")
    expect(page).to have_content("Polly")
  end

  it "Handle validation errors" do
    user = create(:user, :carrier)

    carrier_sign_in(user)
    visit new_dashboard_account_path
    click_button "Create Account"

    expect(page).to have_content("can't be blank")
  end

  it "Update an account" do
    user = create(:user, :carrier)
    account = create(
      :account,
      :enabled,
      carrier: user.carrier
    )
    sip_trunk = create(:sip_trunk, carrier: user.carrier, name: "Main SIP Trunk")

    carrier_sign_in(user)
    visit dashboard_account_path(account)
    click_link("Edit")
    uncheck("Enabled")
    select("Main SIP Trunk", from: "SIP trunk")
    fill_in("Owner's name", with: "John Doe")
    fill_in("Owner's email", with: "johndoe@example.com")

    perform_enqueued_jobs do
      click_button "Update Account"
    end

    expect(page).to have_content("Account was successfully updated")
    expect(page).to have_link(
      "Main SIP Trunk", href: dashboard_sip_trunk_path(sip_trunk)
    )
    expect(page).to have_content("Disabled")
    expect(page).to have_content("Customer managed")
    expect(page).to have_content("John Doe")
    expect(page).to have_content("johndoe@example.com")
    expect(last_email_sent).to deliver_to("johndoe@example.com")
  end

  it "Resend invitation" do
    user = create(:user, :carrier, :admin)
    account = create(:account, carrier: user.carrier)
    invited_user = create(:user, :invited, email: "johndoe@example.com")
    create(:account_membership, :owner, account:, user: invited_user)

    carrier_sign_in(user)
    visit dashboard_account_path(account)

    expect(page).to have_content("The account owner has not yet accepted their invite.")

    perform_enqueued_jobs do
      click_on("Resend")
    end

    expect(page).to have_content("An invitation email has been sent to johndoe@example.com.")
    expect(page).to have_current_path(dashboard_account_path(account))
    expect(last_email_sent).to deliver_to("johndoe@example.com")
  end

  it "Delete an account" do
    user = create(:user, :carrier)
    account = create(
      :account,
      name: "Rocket Rides",
      carrier: user.carrier
    )

    carrier_sign_in(user)
    visit dashboard_account_path(account)

    click_on "Delete"

    expect(page).not_to have_content("Rocket Rides")
  end
end
