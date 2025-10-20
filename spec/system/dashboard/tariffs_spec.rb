require "rails_helper"

RSpec.describe "Tariffs" do
  it "filter tariffs" do
    carrier = create(:carrier)
    message_tariff = create(:tariff, :message, carrier:, name: "International")
    call_tariff = create(:tariff, :call, carrier:, name: "International")
    local_tariff = create(:tariff, :call, carrier:, name: "Local")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariffs_path(filter: { name: "International", category: "call" })

    expect(page).to have_content(call_tariff.id)
    expect(page).to have_no_content(message_tariff.id)
    expect(page).to have_no_content(local_tariff.id)
  end

  it "create a message tariff", :js do
    carrier = create(:carrier, billing_currency: "VND")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariffs_path
    click_on("New")

    fill_in("Name", with: "International Messages")
    select("Message", from: "Category")
    fill_in("Description", with: "Tariff for international messages")
    fill_in("Message rate", with: "1317.18")
    click_on("Create Tariff")

    expect(page).to have_content("Tariff was successfully created.")
    expect(page).to have_content("International Messages")
    expect(page).to have_content("Tariff for international messages")
    expect(page).to have_content("1,317.18 ₫")
  end

  it "create a call tariff", :js do
    carrier = create(:carrier, billing_currency: "USD")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariffs_path
    click_on("New")

    fill_in("Name", with: "International Calls")
    select("Call", from: "Category")
    fill_in("Per minute rate", with: "0.014")
    fill_in("Connection fee", with: "0.02")
    click_on("Create Tariff")

    expect(page).to have_content("Tariff was successfully created.")
    expect(page).to have_content("International Calls")
    expect(page).to have_content("$0.014")
    expect(page).to have_content("$0.02")
  end

  it "handle validation errors when creating a tariff" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_tariff_path

    click_on("Create Tariff")

    expect(page).to have_content("can't be blank")
  end

  it "show a tariff" do
    carrier = create(:carrier)
    tariff = create(:tariff, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_path(tariff)

    expect(page).to have_link("Manage", href: dashboard_destination_tariffs_path(filter: { tariff_id: tariff.id }))
  end

  it "update a tariff", :js do
    carrier = create(:carrier, billing_currency: "USD")
    tariff = create(:tariff, :call, carrier:, name: "Old Name")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_path(tariff)
    click_on("Edit")

    fill_in("Name", with: "New Name")
    fill_in("Per minute rate", with: "0.05")
    fill_in("Connection fee", with: "0.1")
    click_on("Update Tariff")

    expect(page).to have_content("Tariff was successfully updated.")
    expect(page).to have_content("New Name")
    expect(page).to have_content("$0.05")
    expect(page).to have_content("$0.1")
  end

  it "deletes a tariff" do
    carrier = create(:carrier)
    tariff = create(:tariff, :call, carrier:, name: "My Tariff")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_path(tariff)
    click_on("Delete")

    expect(page).to have_content("Tariff was successfully destroyed.")
    expect(page).to have_no_content("My Tariff")
  end
end
