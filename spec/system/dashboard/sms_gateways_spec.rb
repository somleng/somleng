require "rails_helper"

RSpec.describe "SMS Gateways" do
  it "List and filter SMS Gateways" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(
      :sms_gateway,
      carrier:,
      name: "Main SMS Gateway"
    )
    create(
      :sms_gateway,
      carrier:,
      name: "Old SMS Gateway"
    )

    carrier_sign_in(user)
    visit dashboard_sms_gateways_path(
      filter: { name: "main" }
    )

    expect(page).to have_text("Main SMS Gateway")
    expect(page).to have_no_text("Old SMS Gateway")
  end

  it "Create a SMS Gateway" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit dashboard_sms_gateways_path
    click_on("New")
    fill_in("Name", with: "Main SMS Gateway")

    within("#sender-configuration") do
      choose("Override")
      fill_in("Sender ID", with: "MyCompany")
    end
    click_on "Create SMS gateway"

    expect(page).to have_text("SMS gateway was successfully created")
    expect(page).to have_text("Main SMS Gateway")
    expect(page).to have_text("MyCompany")
    within("#sender-id-behavior") do
      expect(page).to have_text("Override")
    end
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit new_dashboard_sms_gateway_path

    fill_in("Sender ID", with: "Invalid Sender ID ***")
    click_on "Create SMS gateway"

    expect(page).to have_text("is invalid")
  end

  it "Show an SMS Gateway" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    sms_gateway = create(
      :sms_gateway,
      :connected,
      carrier:,
      name: "My SMS Gateway"
    )

    carrier_sign_in(user)
    visit dashboard_sms_gateway_path(sms_gateway)

    expect(page).to have_text("My SMS Gateway")
    expect(page).to have_text("Connected")
  end

  it "Update a SMS Gateway", :js do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    sms_gateway = create(
      :sms_gateway,
      :override,
      carrier:,
      name: "My SMS Gateway",
      sender_id: "123456",
    )

    carrier_sign_in(user)
    visit dashboard_sms_gateway_path(sms_gateway)

    click_on("Edit")
    fill_in("Name", with: "Main SMS Gateway")
    within("#sender-configuration") do
      choose("Passthrough")
    end

    click_on "Update SMS gateway"

    expect(page).to have_text("SMS gateway was successfully updated")
    expect(page).to have_text("Main SMS Gateway")
    expect(page).to have_no_text("123456")
    within("#sender-id") do
      expect(page).to have_text("Not specified")
    end
    within("#sender-id-behavior") do
      expect(page).to have_text("Passthrough")
    end
  end

  it "Delete a SMS Gateway" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    sms_gateway = create(:sms_gateway, carrier:, name: "My SMS Gateway")
    channel_group = create(:sms_gateway_channel_group, sms_gateway:)
    create(:sms_gateway_channel, sms_gateway:, channel_group:)

    carrier_sign_in(user)
    visit dashboard_sms_gateway_path(sms_gateway)

    click_on("Delete")

    expect(page).to have_text("SMS gateway was successfully destroyed")
    expect(page).to have_no_text("My SMS Gateway")
  end
end
