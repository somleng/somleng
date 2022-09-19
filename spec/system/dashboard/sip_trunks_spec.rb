require "rails_helper"

RSpec.describe "SIP Trunks" do
  it "List and filter SIP trunks" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(
      :sip_trunk,
      carrier:,
      name: "Main SIP Trunk",
      created_at: Time.utc(2021, 12, 1)
    )
    create(
      :sip_trunk,
      carrier:,
      name: "Old SIP Trunk",
      created_at: Time.utc(2021, 10, 10)
    )

    carrier_sign_in(user)
    visit dashboard_sip_trunks_path(
      filter: { from_date: "01/12/2021", to_date: "15/12/2021" }
    )

    expect(page).to have_content("Main SIP Trunk")
    expect(page).not_to have_content("Old SIP Trunk")
  end

  it "Create a SIP Trunk" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit dashboard_sip_trunks_path
    click_link("New")
    fill_in("Name", with: "Main SIP Trunk")
    choose("IP address")
    fill_in("Source IP", with: "175.100.7.240")
    fill_in("Host", with: "sip.example.com:5061")
    fill_in("Dial string prefix", with: "123456")
    check("Trunk prefix")
    check("Plus prefix")

    click_button "Create SIP trunk"

    expect(page).to have_content("SIP trunk was successfully created")
    expect(page).to have_content("IP address")
    expect(page).to have_content("175.100.7.240")
    expect(page).to have_content("+1234560XXXXXXXX@sip.example.com:5061")
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit new_dashboard_sip_trunk_path
    click_button "Create SIP trunk"

    expect(page).to have_content("can't be blank")
  end

  it "Update a SIP Trunk" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    sip_trunk = create(
      :sip_trunk,
      carrier:,
      name: "My Trunk",
      inbound_source_ip: "175.100.7.111",
      outbound_host: "sip.example.com:5061",
      outbound_dial_string_prefix: "1234",
      outbound_trunk_prefix: true,
      outbound_plus_prefix: true
    )

    carrier_sign_in(user)
    visit dashboard_sip_trunk_path(sip_trunk)

    click_link("Edit")
    fill_in("Name", with: "Main Trunk")
    fill_in("Source IP", with: "96.9.66.131")
    fill_in("Trunk prefix replacement", with: "855")
    fill_in("Host", with: "96.9.66.131")
    fill_in("Dial string prefix", with: "")
    uncheck("Trunk prefix")
    uncheck("Plus prefix")

    click_button "Update SIP trunk"

    expect(page).to have_content("SIP trunk was successfully updated")
    expect(page).to have_content("Main Trunk")
    expect(page).to have_content("96.9.66.131")
    expect(page).to have_content("855")
    expect(page).to have_content("XXXXXXXXXXX@96.9.66.131")
  end

  it "Delete a SIP Trunk" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    sip_trunk = create(:sip_trunk, carrier:, name: "My SIP Trunk")
    create(:phone_call, carrier:, sip_trunk:)

    carrier_sign_in(user)
    visit dashboard_sip_trunk_path(sip_trunk)

    click_on("Delete")

    expect(page).to have_content("SIP trunk was successfully destroyed")
    expect(page).not_to have_content("My SIP Trunk")
  end
end
