require "rails_helper"

RSpec.describe "Inbound SIP Trunks" do
  it "List and filter inbound SIP trunks" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier: carrier)
    create(:inbound_sip_trunk, carrier: carrier, name: "Main SIP Trunk", created_at: Time.utc(2021, 12, 1))
    create(:inbound_sip_trunk, carrier: carrier, name: "Old SIP Trunk", created_at:  Time.utc(2021, 10, 10))

    sign_in(user)
    visit dashboard_inbound_sip_trunks_path(
      filter: { from_date: "01/12/2021", to_date: "15/12/2021" }
    )

    expect(page).to have_content("Main SIP Trunk")
    expect(page).not_to have_content("Old SIP Trunk")
  end

  it "Create an inbound SIP Trunk" do
    user = create(:user, :carrier, :admin)

    sign_in(user)
    visit dashboard_inbound_sip_trunks_path
    click_link("New")
    fill_in("Name", with: "Main SIP Trunk")
    fill_in("Source IP", with: "175.100.7.240")

    perform_enqueued_jobs do
      click_button "Create Inbound SIP trunk"
    end

    expect(page).to have_content("Inbound SIP trunk was successfully created")
    expect(page).to have_content("175.100.7.240")
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    sign_in(user)
    visit new_dashboard_inbound_sip_trunk_path
    click_button "Create Inbound SIP trunk"

    expect(page).to have_content("can't be blank")
  end

  it "Update an inbound SIP Trunk" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier: carrier)
    inbound_sip_trunk = create(
      :inbound_sip_trunk,
      carrier: carrier,
      name: "My Trunk",
      source_ip: "175.100.7.111"
    )

    sign_in(user)
    visit dashboard_inbound_sip_trunk_path(inbound_sip_trunk)

    click_link("Edit")
    fill_in("Name", with: "Main Trunk")
    fill_in("Source IP", with: "96.9.66.131")
    fill_in("Trunk prefix replacement", with: "855")

    perform_enqueued_jobs do
      click_button "Update Inbound SIP trunk"
    end

    expect(page).to have_content("Inbound SIP trunk was successfully updated")
    expect(page).to have_content("Main Trunk")
    expect(page).to have_content("96.9.66.131")
    expect(page).to have_content("855")
  end

  it "Delete an inbound SIP Trunk" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier: carrier)
    inbound_sip_trunk = create(:inbound_sip_trunk, carrier: carrier, name: "My SIP Trunk")

    sign_in(user)
    visit dashboard_inbound_sip_trunk_path(inbound_sip_trunk)

    perform_enqueued_jobs do
      click_link("Delete")
    end

    expect(page).to have_content("Inbound SIP trunk was successfully destroyed")
    expect(page).not_to have_content("My SIP Trunk")
  end
end
