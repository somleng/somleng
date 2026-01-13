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
    click_on("Filter")
    check("Status")
    select("Enabled", from: "filter[status]")
    check("Metadata")
    fill_in("Key", with: "customer.id")
    fill_in("Value", with: "RR1234")
    click_on("Done")

    expect(page).to have_content("Filter 3")
    expect(page).to have_content("Rocket Rides")
    expect(page).to have_no_content("Garry Gas")
    expect(page).to have_no_content("Alice Apples")
    expect(page).to have_no_content("Disabled Account")
    expect(page).to have_no_content("Carrier Account")
  end

  it "Create an account" do
    carrier = create(:carrier, :with_default_tariff_package)
    create(
      :tariff_package_plan,
      package: carrier.default_tariff_package,
      plan: create(:tariff_plan, :outbound_calls, carrier:, name: "Standard")
    )
    user = create(:user, :carrier, carrier:)

    stub_rating_engine_request
    carrier_sign_in(user)
    visit dashboard_accounts_path
    click_on("New")

    fill_in "Name", with: "Rocket Rides"
    fill_in "Calls per second", with: 2
    enhanced_select("Basic.Slt", from: "Default TTS voice")
    check("Billing enabled")
    enhanced_select("Prepaid", from: "Billing mode")
    click_on("Create Account")

    expect(page).to have_content("Account was successfully created")
    within("#voice") do
      expect(page).to have_content("Calls per second")
      expect(page).to have_content("2")
    end

    expect(page).to have_content("Rocket Rides")
    expect(page).to have_content("Enabled")
    expect(page).to have_link("Edit")
    expect(page).to have_content("Auth Token")
    expect(page).to have_content("Carrier managed")
    expect(page).to have_content("Basic.Slt (Female, en-US)")
    within("#billing") do
      within("#billing-enabled") do
        expect(page).to have_content("Yes")
      end
      expect(page).to have_content("Prepaid")
      expect(page).to have_link("Outbound calls (Standard)")
    end
  end

  it "Handle validation errors" do
    user = create(:user, :carrier)

    carrier_sign_in(user)
    visit new_dashboard_account_path
    click_on("Create Account")

    expect(page).to have_content("can't be blank")
  end

  it "Show an account" do
    carrier = create(:carrier, billing_currency: "USD")
    account = create(:account, carrier:)
    user = create(:user, :carrier, carrier: account.carrier)

    carrier_sign_in(user)
    visit dashboard_account_path(account)

    within("#billing") do
      expect(page).to have_content("United States Dollar")
      expect(page).to have_link("Manage", href: dashboard_phone_number_plans_path(filter: { account_id: account.id }))
    end

    within("#voice") do
      expect(page).to have_link(
        "View",
        href: dashboard_phone_calls_path(filter: { account_id: account.id })
      )
    end

    within("#tts") do
      expect(page).to have_link(
        "View",
        href: dashboard_tts_events_path(filter: { account_id: account.id })
      )
    end

    within("#messaging") do
      expect(page).to have_link(
        "View",
        href: dashboard_messages_path(filter: { account_id: account.id })
      )

      expect(page).to have_link(
        "Manage",
        href: dashboard_messaging_services_path(filter: { account_id: account.id })
      )
    end
  end

  it "Update an account" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    account = create(
      :account,
      :carrier_managed,
      :enabled,
      billing_enabled: true,
      carrier: user.carrier,
      default_tts_voice: "Basic.Kal"
    )
    sip_trunk = create(:sip_trunk, carrier:, name: "Main SIP Trunk")

    stub_rating_engine_request
    carrier_sign_in(user)
    visit dashboard_account_path(account)
    click_on("Edit")
    enhanced_select("Main SIP Trunk", from: "SIP trunk")
    fill_in("Owner's name", with: "John Doe")
    fill_in("Owner's email", with: "johndoe@example.com")
    enhanced_select("Basic.Slt", from: "Default TTS voice")
    uncheck("Billing enabled")
    uncheck("Enabled")

    perform_enqueued_jobs do
      click_on("Update Account")
    end

    expect(page).to have_content("Account was successfully updated")
    expect(page).to have_link(
      "Main SIP Trunk", href: dashboard_sip_trunk_path(sip_trunk)
    )
    expect(page).to have_content("Disabled")
    expect(page).to have_content("Customer managed")
    expect(page).to have_content("John Doe")
    expect(page).to have_content("johndoe@example.com")
    expect(page).to have_content("Basic.Slt (Female, en-US)")
    within("#billing-enabled") do
      expect(page).to have_content("No")
    end
    expect(last_email_sent).to deliver_to("johndoe@example.com")
  end

  it "Remove a SIP trunk" do
    user = create(:user, :carrier)
    sip_trunk = create(:sip_trunk, carrier: user.carrier, name: "Main SIP Trunk")
    account = create(
      :account,
      sip_trunk:,
      carrier: user.carrier
    )

    stub_rating_engine_request
    carrier_sign_in(user)
    visit edit_dashboard_account_path(account)

    enhanced_select("", from: "SIP trunk")
    click_on("Update Account")

    expect(page).to have_content("Account was successfully updated")
    expect(page).to have_no_link(
      "Main SIP Trunk"
    )
  end

  it "Update a customer managed account" do
    carrier = create(:carrier)
    create(:sip_trunk, carrier:, name: "Main SIP Trunk")
    tariff_plan = create(:tariff_plan, :outbound_messages, name: "Standard", carrier:)
    account = create(
      :account,
      :customer_managed,
      :enabled,
      carrier:,
      default_tts_voice: "Basic.Slt",
    )
    existing_tariff_plan_subscription = create(
      :tariff_plan_subscription,
      account:,
      plan: create(
        :tariff_plan,
        :outbound_calls,
        carrier:,
        name: "Standard"
      )
    )
    user = create(:user, :carrier, carrier:)

    stub_rating_engine_request
    carrier_sign_in(user)
    visit edit_dashboard_account_path(account)

    expect(page).to have_field("Name", disabled: true)
    expect(page).to have_enhanced_select("Default TTS voice", disabled: true)

    enhanced_select("Main SIP Trunk", from: "SIP trunk")
    within(".outbound-messages-line-item") do
      enhanced_select("Outbound messages (Standard)", from: "Plan")
    end

    click_on("Update Account")

    expect(page).to have_content("Account was successfully updated")
    expect(page).to have_content("Basic.Slt (Female, en-US)")
    expect(page).to have_content("Customer managed")
    expect(page).to have_link(
      "Outbound messages (Standard)",
      href: dashboard_tariff_plan_path(tariff_plan)
    )
    expect(page).to have_link(
      "Outbound calls (Standard)",
      href: dashboard_tariff_plan_path(existing_tariff_plan_subscription.plan)
    )
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
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    account = create(
      :account,
      name: "Rocket Rides",
      carrier:,
    )

    stub_rating_engine_request
    carrier_sign_in(user)
    visit dashboard_account_path(account)

    click_on "Delete"

    expect(page).to have_no_content("Rocket Rides")
  end
end
