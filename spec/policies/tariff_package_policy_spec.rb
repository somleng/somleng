require "rails_helper"

RSpec.describe TariffPackagePolicy, type: :policy do
  it "denies access for destroying tariff packages other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :member, carrier:)
    tariff_package = build_stubbed(:tariff_package, carrier:)

    policy = TariffPackagePolicy.new(user, tariff_package)

    expect(policy).to be_read
    expect(policy).not_to be_manage
  end
  it "denies access tariff packages other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :customer, carrier:)
    tariff_package = build_stubbed(:tariff_package, carrier:)

    policy = TariffPackagePolicy.new(user, tariff_package)

    expect(policy).not_to be_read
    expect(policy).not_to be_manage
  end
end
