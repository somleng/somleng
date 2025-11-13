require "rails_helper"

RSpec.describe "SIP Trunks" do
  it "List and filter SIP trunks" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(
      :sip_trunk,
      carrier:,
      region: :hydrogen,
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
    expect(page).to have_content("South East Asia (Singapore)")
    expect(page).to have_no_content("Old SIP Trunk")
  end

  it "Create a SIP Trunk", :js do
    user = create(:user, :carrier, :admin)
    carrier_sign_in(user)
    visit dashboard_sip_trunks_path

    click_on("New")

    expect(page).to have_content("Select the closest region. The following IP address will be used for media and signaling when connecting to your SIP trunk in the South East Asia (Singapore) region: 13.250.230.15. Please make sure it's allowed on your firewall.")

    fill_in("Name", with: "Main SIP Trunk")
    choose("IP address")
    fill_in("Source IP addresses", with: "175.100.7.240, 175.100.7.241")
    select("Mexico", from: "Default country code")
    fill_in("Host", with: "sip.example.com:5061")
    fill_in("Dial string prefix", with: "123456")
    fill_in("Default sender", with: "+1 (234) 234-5678")
    check("National dialing")
    check("Plus prefix")
    fill_in("Route prefixes", with: "85510, 85515, 85516, 85516")

    click_on("Create SIP trunk")

    expect(page).to have_content("SIP trunk was successfully created")
    expect(page).to have_content("South East Asia (Singapore)")
    expect(page).to have_content("13.250.230.15")
    expect(page).to have_content("IP address")
    expect(page).to have_content("175.100.7.240, 175.100.7.241")
    expect(page).to have_content("Mexico (52)")
    expect(page).to have_content("+1234560XXXXXXXX@sip.example.com:5061")
    expect(page).to have_content("Unlimited")
    expect(page).to have_content("+1 (234) 234-5678")
    expect(page).to have_content("85510, 85515, 85516")
  end

  it "Creates a SIP trunk with client credentials", :js do
    carrier = create(:carrier, country_code: "LA")
    user = create(:user, :carrier, :admin, carrier:)

    carrier_sign_in(user)
    visit dashboard_sip_trunks_path
    click_on("New")
    choose("Client credentials")
    fill_in("Name", with: "Main SIP Trunk")
    fill_in("Max channels", with: 32)
    fill_in("Dial string prefix", with: "123456")
    check("National dialing")
    uncheck("Plus prefix")

    click_on("Create SIP trunk")

    expect(page).to have_content("SIP trunk was successfully created")
    expect(page).to have_content("Username")
    expect(page).to have_content("Password")
    expect(page).to have_content("Lao People's Democratic Republic (856)")
    expect(page).to have_content("sip.somleng.org")
    expect(page).to have_content("32")
    expect(page).to have_content("1234560XXXXXXXX@your-sip-registration-ip")
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit new_dashboard_sip_trunk_path
    click_on("Create SIP trunk")

    expect(page).to have_content("can't be blank")
  end

  it "Update a SIP Trunk" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    sip_trunk = create(
      :sip_trunk,
      carrier:,
      name: "My Trunk",
      inbound_source_ips: "175.100.7.111",
      outbound_host: "sip.example.com:5061",
      outbound_dial_string_prefix: "1234",
      outbound_national_dialing: true,
      outbound_plus_prefix: true,
      default_sender: "123456",
      region: :helium
    )

    carrier_sign_in(user)
    visit dashboard_sip_trunk_path(sip_trunk)

    click_on("Edit")

    expect(page).to have_select("Region", selected: "North America (N. Virginia, USA)")
    fill_in("Name", with: "Main Trunk")
    select("South East Asia (Singapore)", from: "Region")
    fill_in("Source IP addresses", with: "96.9.66.131, 96.9.66.132")
    select("Cambodia", from: "Default country code")
    fill_in("Host", with: "96.9.66.132")
    fill_in("Dial string prefix", with: "")
    fill_in("Default sender", with: "")
    uncheck("National dialing")
    uncheck("Plus prefix")

    click_on("Update SIP trunk")

    expect(page).to have_content("SIP trunk was successfully updated")
    expect(page).to have_content("Main Trunk")
    expect(page).to have_content("South East Asia (Singapore)")
    expect(page).to have_content("96.9.66.131, 96.9.66.132")
    expect(page).to have_content("Cambodia")
    expect(page).to have_content("XXXXXXXXXXX@96.9.66.132")
    expect(page).to have_no_content("123456")
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
    expect(page).to have_no_content("My SIP Trunk")
  end
end
