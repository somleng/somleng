require "rails_helper"

RSpec.describe DestinationTariffPolicy, type: :policy do
  it "denies access for destroying destination tariffs other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :member, carrier:)
    destination_tariff = build_stubbed(:destination_tariff, carrier:)

    policy = DestinationTariffPolicy.new(user, destination_tariff)

    expect(policy).to be_read
    expect(policy).not_to be_manage
  end

  it "denies access destination tariffs other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :customer, carrier:)
    destination_tariff = build_stubbed(:destination_tariff, carrier:)

    policy = DestinationTariffPolicy.new(user, destination_tariff)

    expect(policy).not_to be_read
    expect(policy).not_to be_manage
  end
end
