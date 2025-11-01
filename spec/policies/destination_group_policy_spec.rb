require "rails_helper"

RSpec.describe DestinationGroupPolicy, type: :policy do
  it "denies access for updating catch alls" do
    user = build_stubbed(:user, :carrier)
    policy = DestinationGroupPolicy.new(user, build_stubbed(:destination_group, catch_all: true))

    expect(policy).not_to be_edit
    expect(policy).not_to be_update
  end
end
