require "rails_helper"

RSpec.describe "SMS Gateway Channel Groups" do
  it "List and filter channel groups" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    sms_gateway = create(:sms_gateway, carrier:)
    create(
      :sms_gateway_channel_group,
      sms_gateway:,
      name: "Smart"
    )
    create(
      :sms_gateway_channel_group,
      sms_gateway:,
      name: "Metfone"
    )

    carrier_sign_in(user)
    visit dashboard_sms_gateway_channel_groups_path(
      filter: { name: "metfone" }
    )

    expect(page).to have_content("Metfone")
    expect(page).not_to have_content("Smart")
  end

  it "Create a new channel group", :js do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    create(:sms_gateway, carrier:, name: "My SMS Gateway", max_channels: 2)
    carrier_sign_in(user)

    visit(dashboard_sms_gateway_channel_groups_path)
    click_on("New")

    expect(page).to have_field("Route prefixes", with: "")
    fill_in("Name", with: "Smart")
    enhanced_select("My SMS Gateway", from: "SMS gateway")
    fill_in("Route prefixes", with: "85515, 85516")
    enhanced_select("1", from: "Channels")
    enhanced_select("2", from: "Channels")
    click_on "Create Channel group"

    expect(page).to have_content("Channel group was successfully created")
    expect(page).to have_content("Smart")
    expect(page).to have_content("85515, 85516")
    expect(page).to have_content("1, 2")
    expect(page).to have_content("2 of 2")
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit new_dashboard_sms_gateway_channel_group_path
    click_on "Create Channel group"

    expect(page).to have_content("can't be blank")
  end

  it "Update a channel group" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    sms_gateway = create(:sms_gateway, carrier:, max_channels: 2)
    channel_group = create(
      :sms_gateway_channel_group,
      sms_gateway:,
      name: "My Channel Group"
    )
    create(:sms_gateway_channel, slot_index: 1, sms_gateway:, channel_group:)

    carrier_sign_in(user)
    visit dashboard_sms_gateway_channel_group_path(channel_group)

    click_on("Edit")
    fill_in("Name", with: "Smart")
    fill_in("Route prefixes", with: "85515")
    select("2", from: "Channels")

    click_on "Update Channel group"

    expect(page).to have_content("Channel group was successfully updated")
    expect(page).to have_content("Smart")
    expect(page).to have_content("85515")
    expect(page).to have_content("2 of 2")
    expect(page).to have_content("1, 2")
  end

  it "Delete a channel group" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    sms_gateway = create(:sms_gateway, carrier:)
    channel_group = create(:sms_gateway_channel_group, sms_gateway:, name: "My Channel Group")
    create(:sms_gateway_channel, channel_group:, sms_gateway:)

    carrier_sign_in(user)
    visit dashboard_sms_gateway_channel_group_path(channel_group)

    click_on("Delete")

    expect(page).to have_content("Channel group was successfully destroyed")
    expect(page).not_to have_content("My Channel Group")
  end
end
