require "rails_helper"

RSpec.describe DestinationGroupPolicy, type: :policy do
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

  it "denies access for updating/destroying destination groups other than carrier admins" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :customer, carrier:)
    create(:account_membership, user:, account:)
    destination_group = create(:destination_group, carrier:)

    policy = DestinationGroupPolicy.new(user, destination_group)

    expect(policy).not_to be_destroy
    expect(policy).not_to be_update
  end
end
