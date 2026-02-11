require "rails_helper"

RSpec.describe "Admin/Tariff Packages" do
 it "List tariff packages" do
    package_plan = create(:tariff_package_plan)

    page.driver.browser.authorize("admin", "password")
    visit admin_tariff_packages_path
    click_on(package_plan.package_id)

    expect(page).to have_content(package_plan.package_id)
    expect(page).to have_content(package_plan.id)

    click_on(package_plan.id)

    expect(page).to have_content(package_plan.id)
  end
end
