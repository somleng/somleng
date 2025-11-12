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

    expect(page).to have_content("Main SMS Gateway")
    expect(page).to have_no_content("Old SMS Gateway")
  end

  it "Create a SMS Gateway" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit dashboard_sms_gateways_path
    click_on("New")
    fill_in("Name", with: "Main SMS Gateway")
    fill_in("Default sender", with: "+1 (234) 234-5678")

    click_on "Create SMS gateway"

    expect(page).to have_content("SMS gateway was successfully created")
    expect(page).to have_content("Main SMS Gateway")
    expect(page).to have_content("+1 (234) 234-5678")
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit new_dashboard_sms_gateway_path
    click_on "Create SMS gateway"

    expect(page).to have_content("can't be blank")
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

    expect(page).to have_content("My SMS Gateway")
    expect(page).to have_content("Connected")
  end

  it "Update a SMS Gateway" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    sms_gateway = create(
      :sms_gateway,
      carrier:,
      name: "My SMS Gateway",
      default_sender: "123456"
    )

    carrier_sign_in(user)
    visit dashboard_sms_gateway_path(sms_gateway)

    click_on("Edit")
    fill_in("Name", with: "Main SMS Gateway")
    fill_in("Default sender", with: "")

    click_on "Update SMS gateway"

    expect(page).to have_content("SMS gateway was successfully updated")
    expect(page).to have_content("Main SMS Gateway")
    expect(page).to have_no_content("123456")
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

    expect(page).to have_content("SMS gateway was successfully destroyed")
    expect(page).to have_no_content("My SMS Gateway")
  end
end
