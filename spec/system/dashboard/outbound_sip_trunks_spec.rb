require "rails_helper"

RSpec.describe "Outbound SIP Trunks" do
  it "List and filter outbound SIP trunks" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier: carrier)
    create(:outbound_sip_trunk, carrier: carrier, name: "Main SIP Trunk", created_at: Time.utc(2021, 12, 1))
    create(:outbound_sip_trunk, carrier: carrier, name: "Old SIP Trunk", created_at:  Time.utc(2021, 10, 10))

    sign_in(user)
    visit dashboard_outbound_sip_trunks_path(
      filter: { from_date: "01/12/2021", to_date: "15/12/2021" }
    )

    expect(page).to have_content("Main SIP Trunk")
    expect(page).not_to have_content("Old SIP Trunk")
  end

  it "Create an outbound SIP Trunk" do
    carrier = create(:carrier, country_code: "KH")
    user = create(:user, :carrier, :admin, carrier: carrier)

    sign_in(user)
    visit dashboard_outbound_sip_trunks_path
    click_link("New")
    fill_in("Name", with: "Main SIP Trunk")
    fill_in("Host", with: "sip.example.com:5061")
    fill_in("Dial string prefix", with: "123456")
    check("Trunk prefix")
    click_button "Create Outbound SIP trunk"

    expect(page).to have_content("Outbound SIP trunk was successfully created")
    expect(page).to have_content("1234560XXXXXXXX@sip.example.com:5061")
  end

  it "Update an outbound SIP Trunk" do
    carrier = create(:carrier, country_code: "KH")
    user = create(:user, :carrier, :admin, carrier: carrier)
    outbound_sip_trunk = create(
      :outbound_sip_trunk,
      carrier: carrier,
      name: "My Trunk",
      host: "sip.example.com:5061",
      dial_string_prefix: "1234",
      trunk_prefix: true
    )

    sign_in(user)
    visit dashboard_outbound_sip_trunk_path(outbound_sip_trunk)
    click_link("Edit")
    fill_in("Name", with: "Main Trunk")
    fill_in("Host", with: "96.9.66.131")
    fill_in("Dial string prefix", with: "")
    uncheck("Trunk prefix")
    click_button "Update Outbound SIP trunk"

    expect(page).to have_content("Outbound SIP trunk was successfully updated")
    expect(page).to have_content("Main Trunk")
    expect(page).to have_content("XXXXXXXXXXX@96.9.66.131")
  end

  it "Delete an outbound SIP Trunk" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier: carrier)
    outbound_sip_trunk = create(:outbound_sip_trunk, carrier: carrier, name: "My SIP Trunk")
    create(:account, outbound_sip_trunk: outbound_sip_trunk)

    sign_in(user)
    visit dashboard_outbound_sip_trunk_path(outbound_sip_trunk)
    click_link("Delete")

    expect(page).to have_content("Outbound SIP trunk was successfully destroyed")
    expect(page).not_to have_content("My SIP Trunk")
  end
end
