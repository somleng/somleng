require "rails_helper"

RSpec.describe DestinationGroupPolicy, type: :policy do
  it "denies access for updating destination groups other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :member, carrier:)
    destination_group = build_stubbed(:destination_group, carrier:)

    policy = DestinationGroupPolicy.new(user, destination_group)

    expect(policy).to be_read
    expect(policy).not_to be_manage
  end

  it "denies access for updating catch alls" do
    user = build_stubbed(:user, :carrier)
    policy = DestinationGroupPolicy.new(user, build_stubbed(:destination_group, catch_all: true))

    expect(policy).not_to be_edit
    expect(policy).not_to be_update
  end

  it "denies access for destroying destination groups with destination tariffs" do
    user = build_stubbed(:user, :carrier)
    destination_group = create(:destination_group)
    create(:destination_tariff, destination_group:)

    policy = DestinationGroupPolicy.new(user, destination_group)

    expect(policy).not_to be_destroy
  end

  it "denies access destination groups other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :customer, carrier:)
    destination_group = build_stubbed(:destination_group, carrier:)

    policy = DestinationGroupPolicy.new(user, destination_group)

    expect(policy).not_to be_read
    expect(policy).not_to be_destroy
    expect(policy).not_to be_update
    expect(policy).not_to be_manage
  end
end
