require "rails_helper"

RSpec.describe TariffPackageWizardPolicy, type: :policy do
  it "denies access for destroying tariff package wizards other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :member, carrier:)
    tariff_package_wizard = TariffPackageWizardForm.new(carrier:)

    policy = TariffPackageWizardPolicy.new(user, tariff_package_wizard)

    expect(policy).not_to be_manage
  end

  it "denies access tariff package wizards other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :customer, carrier:)
    tariff_package_wizard = TariffPackageWizardForm.new(carrier:)

    policy = TariffPackageWizardPolicy.new(user, tariff_package_wizard)

    expect(policy).not_to be_manage
  end
end
