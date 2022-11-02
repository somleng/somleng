require "rails_helper"

RSpec.describe "SMS Gateway Channels" do
  it "List and filter channels" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    sms_gateway = create(:sms_gateway, carrier:)
    create(
      :sms_gateway_channel,
      sms_gateway:,
      name: "Metfone 1"
    )
    create(
      :sms_gateway_channel,
      sms_gateway:,
      name: "Smart 1"
    )

    carrier_sign_in(user)
    visit dashboard_sms_gateway_channels_path(
      filter: { name: "metfone" }
    )

    expect(page).to have_content("Metfone 1")
    expect(page).not_to have_content("Smart 1")
  end

  it "Create a new channel" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    create(:sms_gateway, carrier:, name: "My SMS Gateway")
    create(:phone_number, carrier:, number: "85516789876")
    carrier_sign_in(user)

    visit(dashboard_sms_gateway_channels_path)
    click_link("New")

    fill_in("Name", with: "Smart 1")
    select("My SMS Gateway", from: "SMS gateway")
    select("85516789876", from: "Phone number")
    fill_in("Route prefixes", with: "85515, 85516")
    click_button "Create Channel"

    expect(page).to have_content("Channel was successfully created")
    expect(page).to have_content("Smart 1")
    expect(page).to have_content("85516789876")
    expect(page).to have_content("85515, 85516")
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit new_dashboard_sms_gateway_channel_path
    click_button "Create Channel"

    expect(page).to have_content("can't be blank")
  end

  it "Update a channel" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    sms_gateway = create(:sms_gateway, carrier:)
    create(
      :sms_gateway_channel_group,
      sms_gateway:,
      name: "Metfone"
    )
    channel = create(:sms_gateway_channel, sms_gateway:)

    carrier_sign_in(user)
    visit dashboard_sms_gateway_channel_path(channel)
    click_link("Edit")

    fill_in("Name", with: "SIM 1")
    select("Metfone", from: "Channel group")
    click_button "Update Channel"

    expect(page).to have_content("Channel was successfully updated")
    expect(page).to have_content("SIM 1")
  end

  it "Delete a channel" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    sms_gateway = create(:sms_gateway, carrier:)
    channel_group = create(:sms_gateway_channel_group, sms_gateway:)
    channel = create(:sms_gateway_channel, channel_group:, sms_gateway:, name: "My Channel")

    carrier_sign_in(user)
    visit dashboard_sms_gateway_channel_path(channel)

    click_on("Delete")

    expect(page).to have_content("Channel was successfully destroyed")
    expect(page).not_to have_content("My Channel")
  end
end
